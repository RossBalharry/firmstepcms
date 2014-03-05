<?php


function _achieveservice_profile_user_profile_validate($form, &$form_state){
  $basic_email_regex = "/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/";
  // if matches an email address
  if (preg_match($basic_email_regex, $form["name"]["#value"])) {
    form_set_error('name', t('Please enter your username, not your email address.'));
    return false;
  }
}

// Replacement for user_account_form_validate
// This functoin doesn't mind duplicate email addresses
function achieveservice_profile_user_account_form_validate($form, &$form_state) {
  if ($form['#user_category'] == 'account' || $form['#user_category'] == 'register') {
    $account = $form['#user'];
    // Validate new or changing username.
    if (isset($form_state['values']['name'])) {
      if ($error = user_validate_name($form_state['values']['name'])) {
        if (module_exists('fam_login') && fam_login_has_fam_account($account) && $error == t("The username contains an illegal character.") && user_access('administer users')) {
          // User has username with a guid because he's a fam user (allow this exception)
        }
        else {
          // If user has a fam account
          form_set_error('name', $error);
        }
      }
      elseif ((bool) db_select('users')->fields('users', array('uid'))->condition('uid', $account->uid, '<>')->condition('name', db_like($form_state['values']['name']), 'LIKE')->range(0, 1)->execute()->fetchField()) {
        form_set_error('name', t('The name %name is already taken.', array('%name' => $form_state['values']['name'])));
      }
    }

    // Trim whitespace from mail, to prevent confusing 'e-mail not valid'
    // warnings often caused by cutting and pasting.
    $mail = trim($form_state['values']['mail']);
    form_set_value($form['account']['mail'], $mail, $form_state);

    // Validate the e-mail address, and check if it is taken by an existing user.
    if ($error = user_validate_mail($form_state['values']['mail'])) {
      form_set_error('mail', $error);
    }

    // Make sure the signature isn't longer than the size of the database field.
    // Signatures are disabled by default, so make sure it exists first.
    if (isset($form_state['values']['signature'])) {
      // Move text format for user signature into 'signature_format'.
      $form_state['values']['signature_format'] = $form_state['values']['signature']['format'];
      // Move text value for user signature into 'signature'.
      $form_state['values']['signature'] = $form_state['values']['signature']['value'];

      $user_schema = drupal_get_schema('users');
      if (drupal_strlen($form_state['values']['signature']) > $user_schema['fields']['signature']['length']) {
        form_set_error('signature', t('The signature is too long: it must be %max characters or less.', array('%max' => $user_schema['fields']['signature']['length'])));
      }
    }
  }
}


function achieveservice_profile_user_register_validate_no_username($form, &$form_state) {
  _achieveservice_profile_set_username_to_email($form, $form_state);
  entity_form_field_validate('user', $form, $form_state);
}

// Replacement for user_account_form_validate
// This function doesn't mind empty username. It sets the username to the email value. 
function achieveservice_profile_user_account_form_validate_no_username($form, &$form_state) {
  if ($form['#user_category'] == 'account' || $form['#user_category'] == 'register') {
    $account = $form['#user'];
    // Validate new or changing username.
    if (isset($form_state['values']['name'])) {

      _achieveservice_profile_set_username_to_email($form, $form_state);

      if ((bool) db_select('users')->fields('users', array('uid'))->condition('uid', $account->uid, '<>')->condition('name', db_like($form_state['values']['name']), 'LIKE')->range(0, 1)->execute()->fetchField()) {
        form_set_error('name', t('The name %name is already taken.', array('%name' => $form_state['values']['name'])));
      }
    }

    // Trim whitespace from mail, to prevent confusing 'e-mail not valid'
    // warnings often caused by cutting and pasting.
    $mail = trim($form_state['values']['mail']);
    form_set_value($form['account']['mail'], $mail, $form_state);

    // Validate the e-mail address, and check if it is taken by an existing user.
    if ($error = user_validate_mail($form_state['values']['mail'])) {
      form_set_error('mail', $error);
    }
    elseif ((bool) db_select('users')->fields('users', array('uid'))->condition('uid', $account->uid, '<>')->condition('mail', db_like($form_state['values']['mail']), 'LIKE')->range(0, 1)->execute()->fetchField()) {
      // Format error message dependent on whether the user is logged in or not.
      if ($GLOBALS['user']->uid) {
        form_set_error('mail', t('The e-mail address %email is already taken.', array('%email' => $form_state['values']['mail'])));
      }
      else {
        form_set_error('mail', t('The e-mail address %email is already registered. <a href="@password">Have you forgotten your password?</a>', array('%email' => $form_state['values']['mail'], '@password' => url('user/password'))));
      }
    }

    // Make sure the signature isn't longer than the size of the database field.
    // Signatures are disabled by default, so make sure it exists first.
    if (isset($form_state['values']['signature'])) {
      // Move text format for user signature into 'signature_format'.
      $form_state['values']['signature_format'] = $form_state['values']['signature']['format'];
      // Move text value for user signature into 'signature'.
      $form_state['values']['signature'] = $form_state['values']['signature']['value'];

      $user_schema = drupal_get_schema('users');
      if (drupal_strlen($form_state['values']['signature']) > $user_schema['fields']['signature']['length']) {
        form_set_error('signature', t('The signature is too long: it must be %max characters or less.', array('%max' => $user_schema['fields']['signature']['length'])));
      }
    }
  }
}