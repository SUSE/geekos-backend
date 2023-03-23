class Crawler::OrgTree < Crawler::BaseCrawler
  ROOT_USERNAME = ENV.fetch('geekos_root_username', nil)

  def run
    super
    raise 'Root user not found. Use Crawler::Ldap.new.run before' unless root

    !!(construct_tree && tree_to_mongo && cleanup!)
  end

  def root
    @root_user ||= User.find(ROOT_USERNAME)
  end

  def tree
    @tree ||= Tree::TreeNode.new(root.fullname, root.employeenumber)
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
      node << construct_tree(node: Tree::TreeNode.new(subordinate.fullname, subordinate.employeenumber))
    end
    node
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
          set_default_orgunit_name(org, user) if org.name.blank?
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

  def set_default_orgunit_name(org, leader)
    leader_titles = [
      'Head of', '(Senior )?Engineering Manager[,\- ]*',
      '(Senior )?Manager[,\- ]*(of)?', 'Team[ ]?lead(er)?[,\- ]*(of)?(for)?',
      'Director[,\- ]*(of)?', '^VP[,\- ]*[of]*', 'Vice President[ of]?'
    ]
    title_match = leader_titles.find { |lt| leader.title =~ /#{lt}/i }
    name = leader.title.gsub(/#{title_match}/i, '').strip if title_match
    name = "#{leader.fullname}'s team" if name.blank?
    log.info "OrgTree -> Setting team name '#{name}'"
    Mongoid::AuditLog.record { org.update!(name:) }
  end
end
