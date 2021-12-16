require 'rails_helper'

describe Crawler::OrgTree do
  describe '#run' do
    subject(:run) { described_class.new.run }

    before do
      create(:user, :ldap, :root)
      allow_any_instance_of(described_class).to receive(:construct_tree).and_return(:foo)
      allow_any_instance_of(described_class).to receive(:tree_to_mongo).and_return(:bar)
    end

    let(:exception_message_user) { 'Root user not found. Use Crawler::Ldap.new.run before' }

    it 'raises when there is no root user' do
      User.destroy_all
      expect { run }.to raise_exception(exception_message_user)
    end

    it 'returns false if there is no tree object' do
      allow_any_instance_of(described_class).to receive(:construct_tree).and_return(nil)
      expect(run).to be false
    end

    it 'returns true if there is a tree object' do
      expect(run).to be true
    end

    it 'calls construct_tree' do
      expect_any_instance_of(described_class).to receive(:construct_tree)
      run
    end

    it 'calls tree_to_mongo' do
      expect_any_instance_of(described_class).to receive(:tree_to_mongo)
      run
    end

    it 'calls cleanup!' do
      expect_any_instance_of(described_class).to receive(:cleanup!)
      run
    end
  end

  describe '#root' do
    subject(:org_tree_root) { described_class.new.root }

    it 'would return a User with Crawler::OrgTree::ROOT_USERNAME as uid' do
      create(:user, :ldap, :root)
      expect(org_tree_root.username).to eq Crawler::OrgTree::ROOT_USERNAME
    end
  end

  describe '#tree' do
    subject(:tree) { described_class.new.tree }

    let!(:root_user) { create(:user, :ldap, :root) }

    it { is_expected.to be_instance_of(Tree::TreeNode) }
    its(:name) { is_expected.to eq root_user.fullname }
    its(:content) { is_expected.to eq root_user.employeenumber }
  end

  describe '#construct_tree' do
    subject(:tree) { described_class.new.construct_tree }

    before do
      root_user = create(:user, :ldap, :root, employeenumber: '1')
      u2 = create(:user, :ldap, employeenumber: '2', manager: root_user)
      _u3 = create(:user, :ldap, employeenumber: '3', manager: root_user)
      u4 = create(:user, :ldap, employeenumber: '4', manager: root_user)
      _u5 = create(:user, :ldap, employeenumber: '5', manager: u2)
      _u6 = create(:user, :ldap, employeenumber: '6', manager: u4)
      _u7 = create(:user, :ldap, employeenumber: '7', manager: u4)
    end

    it 'has 3 leafs' do
      expect(tree.children.size).to be 3
    end

    its 'first child has one leaf' do
      first_child_name = tree.children.first.name

      expect(tree[first_child_name].children.size).to eq 1
    end

    its 'second child has no leafs' do
      second_child_name = tree.children[1].name

      expect(tree[second_child_name].children.size).to eq 0
    end

    its 'third child has two leafs' do
      third_child_name = tree.children[2].name

      expect(tree[third_child_name].children.size).to eq 2
    end
  end

  describe '#cleanup!' do
    subject { OrgUnit }

    context 'org unit without lead' do
      before do
        unit = create(:org_unit)
        unit.lead.destroy
        described_class.new.cleanup!
      end

      its(:count) { is_expected.to eq 0 }
    end

    context 'org unit without a team left' do
      before do
        create(:org_unit)
        described_class.new.cleanup!
      end

      its(:count) { is_expected.to eq 0 }
    end
  end

  describe '#tree_to_mongo' do
    let(:root_user) do
      create(:user, :ldap, :root)
    end

    let(:tree) do
      tree = Tree::TreeNode.new('CEO', root_user.employeenumber)
      tree << Tree::TreeNode.new('VP of foo', 2)
      tree << Tree::TreeNode.new('VP of bar', 3)
      tree << Tree::TreeNode.new('VP of baz', 4)

      vp_of_bar = tree.root['VP of bar']
      vp_of_bar << Tree::TreeNode.new('DL of sticks', 5)
      vp_of_bar << Tree::TreeNode.new('DL of circles', 6)
      vp_of_bar << Tree::TreeNode.new('DL of triangles', 7)

      department_of_sticks = tree.root['VP of bar']['DL of sticks']
      department_of_sticks << Tree::TreeNode.new('TL of ninjas', 8)
      department_of_sticks << Tree::TreeNode.new('TL of pandas', 9)
      department_of_sticks << Tree::TreeNode.new('TL of pajamas', 10)

      team_of_ninjas = tree.root['VP of bar']['DL of sticks']['TL of ninjas']
      team_of_ninjas << Tree::TreeNode.new('Dev1', 11)
      team_of_ninjas << Tree::TreeNode.new('Dev2', 12)
      team_of_ninjas << Tree::TreeNode.new('Dev3', 13)
      team_of_ninjas << Tree::TreeNode.new('Dev4', 14)
      team_of_ninjas << Tree::TreeNode.new('Dev5', 15)
      tree
    end

    def setup_users
      tree.each do |member|
        next unless member.parent # root user already created above

        create(:user, :ldap, manager: User.find(member.parent.content), employeenumber: member.content)
      end
    end

    before do
      setup_users
      allow_any_instance_of(described_class).to receive(:tree).and_return(tree)
      described_class.new.tree_to_mongo
    end

    it 'creates orgunit only if the head of it has subordinates' do
      expect(OrgUnit.count).to be 4
    end

    it 'defaults orgunit name to lead name' do
      unit = OrgUnit.find_by(depth: 3)
      expect(unit.name).to eq "#{unit.lead.fullname}'s team"
    end

    it 'skips leaf creation if user is not found' do
      User.last.destroy
      allow_any_instance_of(OrgUnit).to receive(:name)
      expect_any_instance_of(ActiveSupport::Logger).to receive(:error).with(/Did not find user/)
      described_class.new.tree_to_mongo
    end

    it 'retains existing org unit name if it was changed' do
      unit = OrgUnit.find_by(depth: 3)
      unit.update!(name: 'Department1')
      described_class.new.tree_to_mongo
      expect(unit.reload.name).to eq 'Department1'
    end
  end
end
