<?php

function achieveservice_ws_services_admin_page() {
  $services = achieveservice_ws_get_services();

  $headers = array('Name', 'Title', 'Source URL/path', 'Linked XSL Stylesheet', 'Actions');
  $rows = array();

  foreach ($services as $service) {
    $row = array(
        $service['name'],
        $service['title'],
        $service['xml_source'],
        );
    $row[] = l($service['xsl_name'], 'admin/structure/achieveservice_ws/stylesheets/'.$service['xsl_name']);
    $actions = array(l('edit', 'admin/structure/achieveservice_ws/services/'.$service['id']));
    $actions[] = l('test', 'admin/structure/achieveservice_ws/services/'.$service['id'].'/test');
    $row[] = implode(' ', $actions);
    $rows[] = $row;
  }
  
//   print '<pre>';
//   print_r($services);
//   exit;

  $output = '<h2>'.t('Services').'</h2>';
  $output .= '<p>'.l('Create new Service', 'admin/structure/achieveservice_ws/services/new').'</p>';
  $output .= theme('table', array('header' => $headers, 'rows' => $rows));
  return $output;
}

function achieveservice_ws_xsl_admin_page() {
  //die('here');
  $stylesheets = achieveservice_ws_get_stylesheets();
//   print '<pre>';
//   print 'here 2';
//   print_r($stylesheets);
//   exit;

  $headers = array('Name', 'Description', 'Source', 'Actions');
  $rows = array();

  foreach ($stylesheets as $sheet) {
    $row = array(
        $sheet['name'],
        $sheet['description'],
        $sheet['source']);
    $actions = l('edit', 'admin/structure/achieveservice_ws/stylesheets/'.$sheet['id']);
    $row[] = $actions;
    $rows[] = $row;
  }

  $output = '<h2>'.t('Stylesheets').'</h2>';
  $output .= '<p>'.l('Create new Stylesheet', 'admin/structure/achieveservice_ws/stylesheets/new').'</p>';
  $output .= theme('table', array('header' => $headers, 'rows' => $rows));
  return $output;
}

function achieveservice_ws_settings_admin_page() {
  
  $form = array();
  $form['achieveservice_ws_redirect_url'] = array(
    '#type'          => 'textfield',
    '#title'         => t('Redirect URL'),
    '#size'          => 30,
    '#default_value' => variable_get('achieveservice_ws_redirect_url', ''),
    '#description'   => t('Redirect URL after filling a form that was got to from one of the services.'),
    '#required'     => TRUE,
  );
  $form['achieveservice_ws_faqs_by_tag'] = array(
    '#type'          => 'checkbox',
    '#title'         => t('Search FAQs by Tag'),
    '#default_value' => variable_get('achieveservice_ws_faqs_by_tag', 0),
  );
  
  return system_settings_form($form);
}

function achieveservice_ws_service_form($form, $form_state, $ws_id) {
  $form = array();
  
  //die($ws_id);

  if ($ws_id == 'new') {
    $service = achieveservice_ws_new_service();
    $form['header'] = array('#value' => '<h2>'.t('Create New Service').'</h2>');
  } else {
    $service = achieveservice_ws_get_service($ws_id);
    if ($service == FALSE) {
      drupal_set_message(t('Service not found.'), 'error');
    }
  }

  $form['service']['id'] = array(
      '#type' => 'value',
      '#value' => $service['id']
      );

  $form['service']['name'] = array(
      '#type' => 'textfield',
      '#title' => t('Machine name'),
      '#description' => t('System name of service, only lowercase letters, underscores, and numbers permitted. Change with care.'),
      '#default_value' => $service['name'],
      '#required' => TRUE,
      );
  $form['service']['title'] = array(
      '#type' => 'textfield',
      '#title' => t('Service title'),
      '#description' => t('Service title used for identification in admin.'),
      '#default_value' => $service['title'],
      '#maxlength' => 255,
      '#required' => TRUE,
      );
  $form['service']['xml_source'] = array(
      '#type' => 'textfield',
      '#title' => t('XML Source'),
      '#description' => t('Document source URL or local path.'),
      '#default_value' => $service['xml_source'],
      '#maxlength' => 1000,
      '#required' => TRUE,
      );
  $form['service']['xsl_id'] = array(
      '#type' => 'select',
      '#title' => t('Stylesheet to apply'),
      '#description' => t('Select the XSL transformation stylesheet to apply to the XML document.'),
      '#default_value' => $service['xsl_id'],
      '#options' => achieveservice_ws_get_stylesheets_list_for_options(),
      );
  $form['service']['renderstyle'] = array(
      '#type' => 'select',
      '#title' => t('Method to use to render the content'),
      '#default_value' => $service['renderstyle'],
      '#options' => array('HTML'=>'HTML','Chart'=>'Chart'),
      );
  $form['service']['searchable'] = array(
      '#type' => 'select',
      '#title' => t('Return results from this feed in the site search. Searchable feeds must return an &lt;item> node for each result. Each &lt;item> should contain &lt;link>, &lt;title> and &lt;snippet>'),
      '#default_value' => $service['searchable'],
      '#options' => array('No'=>'No','Yes'=>'Yes'),
      );


  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => ($service['id'] ? t('Save') : t('Create')),
      );

  if ($service['id']) {
    $form['delete'] = array(
        '#type' => 'submit',
        '#value' => t('Delete'),
        '#name' => 'delete',
        );
  }

  $form['cancel'] = array('#value' => l('Cancel', 'admin/structure/achieveservice_ws/services'));

  return $form;
}

function achieveservice_ws_service_form_submit(&$form, $form_state) {
  // Extract values from the form (surely there is a better way?)
  $service_values = array();
  foreach ($form['service'] as $key => $values) {
    if (is_array($values) && in_array('#value', $values)) $service_values[$key] = $values['#value'];
  }

  #var_dump($service_values);

  // Delete button clicked
  if ($form_state['clicked_button']['#name'] == 'delete') {
    if (achieveservice_ws_delete_service($service_values['id'])) {
      drupal_set_message(t('Service deleted.'));
      $form['#redirect'] = 'admin/structure/achieveservice_ws/services';
      return;
    } else {
      drupal_set_message(t('Service could not be deleted.'), 'error');
      return;
    }
  }

  if ($form['service']['id']['#value']) {
    // Update
    if (achieveservice_ws_save_service($service_values)) {
      drupal_set_message(t('Service updated.'));
    } else {
      drupal_set_message(t('Service could not be updated.'), 'error');
    }
  } else {
    // Create
    $new_service = achieveservice_ws_new_service($service_values);
    if (achieveservice_ws_save_service($new_service)) {
      drupal_set_message(t('New service created.'));
    } else {
      drupal_set_message(t('New service could not be created.'), 'error');
    }
  }
}

function achieveservice_ws_xsl_form($form, $form_state, $xsl_id) {
  $form = array();

  if ($xsl_id == 'new') {
    $xsl = achieveservice_ws_new_stylesheet();
    $form['header'] = array('#value' => '<h2>'.t('Create new Stylesheet').'</h2>');
  } else {
    $xsl = achieveservice_ws_get_stylesheet($xsl_id);
    $form['header'] = array('#value' => '<h2>'.t('Edit Stylesheet').'</h2>');
  }

  $form['stylesheet']['id'] = array(
      '#type' => 'value',
      '#value' => $xsl['id']
      );

  $form['stylesheet']['name'] = array(
      '#type' => 'textfield',
      '#title' => t('Machine name'),
      '#description' => t('System name of stylesheet, should be lowercase characters, numbers, and underscores. Change with care.'),
      '#default_value' => $xsl['name'],
      '#required' => TRUE,
      );

  $form['stylesheet']['description'] = array(
      '#type' => 'textfield',
      '#title' => t('Description'),
      '#description' => t('Purpose of stylesheet'),
      '#default_value' => $xsl['description'],
      '#required' => TRUE,
      );

  $form['stylesheet']['source'] = array(
      '#type' => 'textfield',
      '#title' => t('Source URL or path'),
      '#description' => t('Full URL or path to an external XSL stylesheet.'),
      '#default_value' => $xsl['source'],
      );

  $form['stylesheet']['document_help'] = array(
      '#value' => '<p>The XSLT should return two elements: &lt;title&gt; should contain the page title. &lt;content&gt; should contain HTML content.</p>'
      );

  $form['stylesheet']['document'] = array(
      '#type' => 'textarea',
      '#title' => t('Document'),
      '#description' => t('Enter a full XSLT document here, this takes precedence over an external source.'),
      '#default_value' => $xsl['document'],
      );

  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => ($xsl['id'] ? t('Save') : t('Create')),
      );

  if ($xsl['id']) {
    $form['delete'] = array(
        '#type' => 'submit',
        '#value' => t('Delete'),
        '#name' => 'delete',
        );
  }

  $form['cancel'] = array('#value' => l('Cancel', 'admin/structure/achieveservice_ws/stylesheets'));

  return $form;
}

function achieveservice_ws_xsl_form_submit(&$form, $form_state) {
  $sheet_values = array();
  foreach ($form['stylesheet'] as $key => $values) {
    if (is_array($values) && in_array('#value', $values)) $sheet_values[$key] = $values['#value'];
  }

  // Delete button clicked
  if ($form_state['clicked_button']['#name'] == 'delete') {
    if (achieveservice_ws_delete_stylesheet($sheet_values['id'])) {
      drupal_set_message(t('Stylesheet deleted.'));
      $form['#redirect'] = 'admin/structure/achieveservice_ws/stylesheets';
      return;
    } else {
      drupal_set_message(t('Stylesheet could not be deleted.'), 'error');
      return;
    }
  }

  // Save or create button
  if ($form['stylesheet']['id']['#value']) {
    // Update
    if ($result = achieveservice_ws_save_stylesheet($sheet_values)) {
      drupal_set_message(t('Service updated.'));
      $form['#redirect'] = 'admin/structure/achieveservice_ws/stylesheets';
    } else {
      drupal_set_message(t('Service could not be updated.'), 'error');
    }
  } else {
    // Create
    $new_sheet = achieveservice_ws_new_stylesheet($sheet_values);
    if (achieveservice_ws_save_stylesheet($new_sheet)) {
      drupal_set_message(t('New stylesheet created.'));
      $form['#redirect'] = 'admin/structure/achieveservice_ws/stylesheets';
    } else {
      drupal_set_message(t('New stylesheet could not be created.'), 'error');
    }
  }
}

function achieveservice_ws_service_test_page($id) {
  $service = achieveservice_ws_get_service($id);
  $service_xml = achieveservice_ws_fetch_service_xml($service);
  
//   print '<pre>';
//   print_r($service);
//   print $service_xml->saveXML();
//   exit;

  if (!$service_xml) {
    watchdog('achieveservice_ws', 'Could not retrieve service XML: @name',
        array('@name' => $name), WATCHDOG_ERROR);
    drupal_set_message(t('Could not retrieve service XML'), 'error');
  }

  $stylesheet_xml = achieveservice_ws_get_xsl($service['xsl_id']);
  
//   print '<pre>';
//   print_r($service);
//   print $stylesheet_xml->saveXML();
//   exit;

  if (!$stylesheet_xml) {
    watchdog('achieveservice_ws', 'Could not retrieve XSLT with ID @id',
        array('@id' => $service['xsl_id']), WATCHDOG_ERROR);
    drupal_set_message(t('Could not find stylesheet.'), 'error');
  }

  $output_xml = achieveservice_ws_apply_xslt($service_xml, $stylesheet_xml);
  
  //die('here 1');

  if ($output_xml) {
    $output = '<div class="output">'.$output_xml->saveXML().'</div>';
    //die('here 2');
    $output .= '<div class="source"><pre>'.check_plain($service_xml->saveXML()).'</pre></div>';
    //die('here 3');
    $output .= '<div class="stylesheet"><pre>'.check_plain($stylesheet_xml->saveXML()).'</pre></div>';
    //die('here 4');
    return $output;
  } else {
    //die('here 5');
    drupal_set_message(t('Error running AchieveService Web Service: @name', array('@name' => $name)), 'error');
    return FALSE;
  }
}
