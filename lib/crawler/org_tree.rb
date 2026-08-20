class Crawler::OrgTree < Crawler::BaseCrawler
  # a default keeps the `:root` factory trait usable where the env var is absent, like ci
  ROOT_USERNAME = ENV.fetch('geekos_root_username', 'root')

  def run
    super
    raise 'Root user not found. Use Crawler::Suseid.new.run before' unless root

    !!(construct_tree && tree_to_mongo && cleanup!)
  end

  def root
    @root_user ||= User.find(ROOT_USERNAME)
  end

  def tree
    @tree ||= Tree::TreeNode.new(tree_node_name(root), root.employeenumber)
  end

  def cleanup!
    log.info 'OrgTree -> Cleaning up empty org units'
    OrgUnit.all.each do |unit|
      if unit.lead.nil?
        log.warn "OrgTree/Cleanup -> Dropping OrgUnit '#{unit.name}' ##{unit.id} as it does not have a lead"
        Mongoid::AuditLog.record { unit.destroy }
      elsif unit.members.empty?
        log.warn "OrgTree/Cleanup -> Dropping empty OrgUnit '#{unit.name}' ##{unit.id}"
        Mongoid::AuditLog.record { unit.destroy }
      end
    end
  end

  def construct_tree(node: tree)
    subordinates = User.find(node.content).subordinates
    # log.debug "OrgTree -> Adding #{node.name} " \
    # "#{' with subordinates ' + subordinates.map(&:username).to_s if subordinates.any?}"
    subordinates.each do |subordinate|
      node << construct_tree(node: Tree::TreeNode.new(tree_node_name(subordinate), subordinate.employeenumber))
    end
    node
  end

  def tree_node_name(user)
    "#{user.fullname} (#{user.employeenumber})"
  end

  def tree_to_mongo
    log.info 'OrgTree -> Merging tree to database'
    tree.each do |tree_node|
      user = User.find(tree_node.content)
      if user
        add_to_parent_unit(user) unless tree_node.is_root?
        if user.subordinates.any?
          org = (user.lead_of_org_unit ||= OrgUnit.new(lead: user))
          # log.info "OrgTree -> Working on orgunit for '#{org.name}'"
          if tree_node.is_root?
            org.parent_id = nil
          else
            parent = user.manager.lead_of_org_unit
            org.parent_id = parent.id
          end
          log.info "OrgTree -> New org unit with lead #{user.username}" if org.new_record?
          Mongoid::AuditLog.record { org.save! && user.save! }
          set_orgunit_name(org, user)
        end
      else
        log.error "OrgTree -> Did not find user for node: #{tree_node.name} (#{tree_node.content})"
      end
    end
  end

  private

  def add_to_parent_unit(user)
    unit = user.manager.lead_of_org_unit
    return if unit.members.include?(user)

    log.info "OrgTree -> Adding #{user.username} to orgunit '#{unit.name}'"
    Mongoid::AuditLog.record { unit.members << user }
  end

  # The division of the lead is the only source for the name. A manual
  # rename in the web ui survives until the next crawl.
  def set_orgunit_name(org, leader)
    division = leader.suseid['division']
    log.warn "OrgTree -> No division for lead #{leader.username}, keeping '#{org.name}'" if division.blank?
    return if division.blank? || division == org.name

    log.info "OrgTree -> Renaming org unit of #{leader.username}: '#{org.name}' -> '#{division}'"
    Mongoid::AuditLog.record { org.update!(name: division) }
  end
end
