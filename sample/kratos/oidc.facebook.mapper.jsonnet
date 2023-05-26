local claims = {
  email_verified: false,
} + std.extVar('claims');

{
  identity: {
    traits: {
      [if 'email' in claims && claims.email_verified then 'email' else null]: claims.email,
      given_name: claims.given_name,
      family_name: claims.family_name,
    },
    metadata_admin: {
      facebook_claims: std.extVar('claims'),
    },
  },
}
