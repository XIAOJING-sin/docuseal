# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # `AccountConfig.value` is serialized into a text column (JSON). Querying with `value: true`
    # can be adapter-dependent, so we fetch and compare in Ruby for correctness.
    private_workspace =
      AccountConfig.find_by(account_id: user.account_id, key: AccountConfig::PRIVATE_WORKSPACE_KEY)&.value == true

    # Base read for all roles
    if private_workspace && user.role != User::ADMIN_ROLE
      # In private workspace mode, non-admin users can only see their own templates.
      can :read, Template, account_id: user.account_id, author_id: user.id
    else
      # CanCan cannot merge an ActiveRecord scope rule with other Template rules when building
      # `Template.accessible_by(...)`. Use a hash/subquery-based condition instead.
      readable_templates = Abilities::TemplateConditions.collection(user, ability: 'manage').select(:id)
      can :read, Template, id: readable_templates
    end

    if user.role == User::ADMIN_ROLE
      can %i[create update destroy], Template, account_id: user.account_id
      can :manage, TemplateFolder, account_id: user.account_id
      can :manage, TemplateSharing, template: { account_id: user.account_id }
      can :manage, Submission, account_id: user.account_id
      can :manage, Submitter, account_id: user.account_id
      can :manage, User, account_id: user.account_id
      can :manage, EncryptedConfig, account_id: user.account_id
      can :manage, AccountConfig, account_id: user.account_id
      can :manage, Account, id: user.account_id
      can :manage, WebhookUrl, account_id: user.account_id
      can :manage, AccessToken, user_id: user.id
      can :manage, EncryptedUserConfig, user_id: user.id
      can :manage, UserConfig, user_id: user.id

      # Pro flags enabled
      can :manage, :bulk_send
      can :manage, :saml_sso
      can :manage, :personalization_advanced
      can :manage, :countless
      can :manage, :reply_to
      can :manage, :tenants
      can :manage, :cfr
    elsif user.role == User::EDITOR_ROLE
      can :create, Template, account_id: user.account_id
      # Editors can always archive (destroy action) templates they authored.
      # In this app, "archive" is implemented via `TemplatesController#destroy` (soft delete).
      can :destroy, Template, account_id: user.account_id, author_id: user.id

      if private_workspace
        can %i[update destroy], Template, account_id: user.account_id, author_id: user.id
        can :manage, Submission, account_id: user.account_id, created_by_user_id: user.id
        can :manage, Submitter, submission: { created_by_user_id: user.id }
      else
        can %i[update], Template, account_id: user.account_id
        can :manage, Submission, account_id: user.account_id
        can :manage, Submitter, account_id: user.account_id
      end
      can :read, TemplateFolder, account_id: user.account_id
    else # viewer
      if private_workspace
        can :read, Template, account_id: user.account_id, author_id: user.id
        can :read, Submission, account_id: user.account_id, created_by_user_id: user.id
      else
        # Keep template visibility consistent with the base `:read, Template` rule above.
        can :read, Submission, account_id: user.account_id
      end
      can :read, TemplateFolder, account_id: user.account_id
    end
  end
end
