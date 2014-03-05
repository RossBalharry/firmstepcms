<?php




/**
  * Implementation of hook_block_view().
  * Substitute user-postcode in blocks.
  */
function achieveservice_profile_block_view_alter(&$data, $block) {
  // Verify the we have raw text content
  if (!isset($data['content']) || !is_string($data['content'])) {
    return;
  }
  
  $userprofile;
  if (strstr($data['content'], '[user-postcode]')) {
    if (isset($data['content'])) {
      $userprofile = achieveservice_profile_getprofile();
      $postcode = isset($userprofile['postcode']) ? (string)$userprofile['postcode'] : '';
      $data['content'] = str_replace("[user-postcode]", $postcode, $data['content']);
    }
    else
      $data['content'] = '';
  }  
  
  if (strstr($data['content'], '[user-fulladdress]')) {
    if (isset($data['content'])) {
      if (!$userprofile)
        $userprofile = achieveservice_profile_getprofile();
        
      $data['content'] = str_replace("[user-fulladdress]", _achieveservice_profile_get_full_address($userprofile), $data['content']);
    }
    else
      $data['content'] = '';
  }

  if (strstr($data['content'], '[user-fulladdressnoformat]')) {
    if (isset($data['content'])) {
      if (!$userprofile)
        $userprofile = achieveservice_profile_getprofile();
        
      $data['content'] = str_replace("[user-fulladdressnoformat]", _achieveservice_profile_get_full_address($userprofile,FALSE), $data['content']);
    }
    else
      $data['content'] = '';
  }
  
  
  if (strstr($data['content'], '[user-uprn]')) {
    if (isset($data['content'])) {
      if (!$userprofile)
        $userprofile = achieveservice_profile_getprofile();
        
      $address = isset($userprofile['uprn']) ? (string)$userprofile['uprn'] : '';
      $address = ($address . ' ' . (isset($userprofile['uprn']) ? (string)$userprofile['uprn'] : ''));
      $data['content'] = str_replace("[user-uprn]", $address, $data['content']);
    }
    else
      $data['content'] = '';
  }
  
}

function _achieveservice_profile_get_full_address($userprofile,$prettyformat=TRUE) {
  $address = "";
  if (isset($userprofile['flat']) && (strlen($userprofile['flat']) > 0)) {
    $address .= (string)$userprofile['flat'];
    $address .= ($prettyformat ? ', ' : ' '); 
  }
  $address .= isset($userprofile['house']) ? ((string)$userprofile['house'] . ' ') : '';
  if (isset($userprofile['street'])) {
    $address .= (string)$userprofile['street'];
    $address .= ($prettyformat ? ', ' : ' '); 
  }
  if (isset($userprofile['locality']) && (strlen($userprofile['locality']) > 0)) {
    $address .= (string)$userprofile['locality'];
    $address .= ($prettyformat ? ', ' : ' '); 
  }
  if (isset($userprofile['town']) && (strlen($userprofile['town']) > 0)) {
    $address .= (string)$userprofile['town'];
    $address .= ($prettyformat ? ', ' : ' '); 
  }
  $address .= isset($userprofile['postcode']) ? (string)$userprofile['postcode'] : '';

  if (strlen(trim($address)) == 0)
    $address = "No address found";

  return $address;
}
