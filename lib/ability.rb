# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Any signed-in user can manage their own preferences/settings.
    can :manage, UserConfig, user_id: user.id
    can :manage, EncryptedUserConfig, user_id: user.id
    can :update, User, id: user.id

    # `AccountConfig.value` is serialized into a text column (JSON). Querying with `value: true`
    # can be adapter-dependent, so we fetch and compare in Ruby for correctness.
    #
    # Product decision: folders are shared, but templates/submissions are private for non-admin users by default.
    # Admins always see everything. If needed, admins can explicitly disable private mode by setting
    # `private_workspace` to false.
    private_workspace_enabled_for_non_admins =
      AccountConfig.find_by(account_id: user.account_id, key: AccountConfig::PRIVATE_WORKSPACE_KEY)&.value != false
    private_workspace = private_workspace_enabled_for_non_admins && user.role != User::ADMIN_ROLE

    # Base read for all roles (must work for BOTH `can?` (instance checks) and `accessible_by`)
    if private_workspace
      # Private workspace: non-admin users only see their own templates.
      can :read, Template, account_id: user.account_id, author_id: user.id
    else
      # Default: users can see templates in their own account.
      can :read, Template, account_id: user.account_id

      # Testing accounts can additionally access templates shared to them via TemplateSharing.
      # (This is the only cross-account visibility currently supported by SQL-friendly rules.)
      if user.account.testing?
        shared_template_ids =
          TemplateSharing.where(account_id: [user.account_id, TemplateSharing::ALL_ID])
                         .select(:template_id)

        can :read, Template, id: shared_template_ids
      end
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
        can :read, Submission, account_id: user.account_id
      end
      can :read, TemplateFolder, account_id: user.account_id
    end
  end
end
