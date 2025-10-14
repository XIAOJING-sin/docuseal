# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Base read for all roles
    can %i[read], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
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
      can %i[create update], Template, account_id: user.account_id
      can :manage, Submission, account_id: user.account_id
      can :manage, Submitter, account_id: user.account_id
      can :read, TemplateFolder, account_id: user.account_id
    else # viewer
      can :read, Template, account_id: user.account_id
      can :read, Submission, account_id: user.account_id
      can :read, TemplateFolder, account_id: user.account_id
    end
  end
end
