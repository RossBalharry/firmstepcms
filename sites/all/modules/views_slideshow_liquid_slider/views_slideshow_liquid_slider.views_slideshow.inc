<?php
/**
 * @file
 * views_slideshow_liquid_slider.views_slideshow.inc
 */

/**
 * Implements hook_views_slideshow_slideshow_info().
 */
function views_slideshow_liquid_slider_views_slideshow_slideshow_info() {
  return array(
    'views_slideshow_liquid_slider' => array(
      'name' => t('Liquid Slider'),
      'accepts' => array(),
      'calls' => array(),
    ),
  );
}

/**
 * Implements hook_views_slideshow_slideshow_type_form().
 */
function views_slideshow_liquid_slider_views_slideshow_slideshow_type_form(&$form, &$form_state, &$view) {
  if (!$library = _views_slideshow_liquid_slider_library_path()) {
    $form['views_slideshow_liquid_slider']['no_liquidslider_js'] = array(
      '#prefix' => '<div style="color: red">',
      '#suffix' => '</div>',
      '#markup' => _views_slideshow_liquid_slider_get_install_error_message(),
    );
  }
 

  $link_options = array('none' => t('None'));

  foreach ($view->display->handler->get_handlers('field') as $field => $handler) {
    $link_options[$field] = $handler->ui_name();
  }

  $form['views_slideshow_liquid_slider']['caption_field'] = array(
    '#type' => 'select',
    '#title' => t('Caption Field'),
    '#multiple' => FALSE,
    '#description' => t('Select a field to be used as an image caption.'),
    '#options' => $link_options,
    '#default_value' => $view->options['views_slideshow_liquid_slider']['caption_field'],
  );


  // Auto Height Settings
  $form['views_slideshow_liquid_slider']['autoheight_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Auto Height'),
    '#weight' => 2,
    '#collapsible' => TRUE,
    '#collapsed' => FALSE,
  );
  $form['views_slideshow_liquid_slider']['autoheight_settings']['autoHeight'] = array(
    '#type' => 'checkbox',
    '#title' => t('Enable/disable the auto height functionality.'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoheight_settings']['autoHeight'],
    '#description' => t('Auto adjusts the height to match the current panel. If false, the height stays at that of the highest panel.'),
  );
  $form['views_slideshow_liquid_slider']['autoheight_settings']['autoHeightMin'] = array(
    '#type' => 'textfield',
    '#title' => t('Auto Height Min'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoheight_settings']['autoHeightMin'],
    '#description' => t('You can set up a minimum height for the slider.'),
  );
  $form['views_slideshow_liquid_slider']['autoheight_settings']['autoHeightEaseDuration'] = array(
    '#type' => 'textfield',
    '#title' => t('Auto Height Ease Duration'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoheight_settings']['autoHeightEaseDuration'],
    '#description' => t('The speed at which the panel\'s height will adjust.'),
  );


  // Auto Slide Settings
  $form['views_slideshow_liquid_slider']['autoslide_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Auto Slide'),
    '#weight' => 3,
    '#collapsible' => TRUE,
    '#collapsed' => FALSE,
  );
  $form['views_slideshow_liquid_slider']['autoslide_settings']['autoSlide'] = array(
    '#type' => 'checkbox',
    '#title' => t('Enable/disable the auto slider functionality.'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoslide_settings']['autoSlide'],
  );
  $form['views_slideshow_liquid_slider']['autoslide_settings']['autoSlideStopWhenClicked'] = array(
    '#type' => 'checkbox',
    '#title' => t('Auto Slide Stop When Clicked'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoslide_settings']['autoSlideStopWhenClicked'],
    '#description' => t('If true, the slider will stop when clicked.'),
  );
  $form['views_slideshow_liquid_slider']['autoslide_settings']['autoSlidePauseOnHover'] = array(
    '#type' => 'checkbox',
    '#title' => t('Auto Slide Pause On Hover'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoslide_settings']['autoSlidePauseOnHover'],
    '#description' => t('If true, the slider will stop on hover.'),
  );
  $form['views_slideshow_liquid_slider']['autoslide_settings']['autoSlideInterval'] = array(
    '#type' => 'textfield',
    '#title' => t('Duration auto slide'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['autoslide_settings']['autoSlideInterval'],
    '#description' => t('The timer for the autoslide. 7000 = 7 seconds.'),
  );

  // Dynamic Tabs Settings
  $form['views_slideshow_liquid_slider']['dynamictabs_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Dynamic Tabs'),
    '#weight' => 4,
    '#collapsible' => TRUE,
    '#collapsed' => FALSE,
  );
  $form['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabs'] = array(
    '#type' => 'checkbox',
    '#title' => t('Dynamic Tabs : Enable/disable the panel tabs.'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabs'],
  );
  $form['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabsAlign'] = array(
    '#type' => 'select',
    '#title' => t('Dynamic Tabs Align'),
    '#multiple' => FALSE,
    '#options' => array('center' => t('Center'),'left' => t('Lelt'),'right' => t('Right')),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabsAlign'],
    '#description' => t('The tabs can align either "center", "left" or "right".'),
  );
  $form['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabsPosition'] = array(
    '#type' => 'select',
    '#title' => t('Dynamic Tabs Position'),
    '#multiple' => FALSE,
    '#options' => array('top' => t('Top'),'bottom' => t('Bottom')),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamictabs_settings']['dynamicTabsPosition'],
    '#description' => t('You can placce the tabs at either the "top" or the "bottom".'),
  );
  $form['views_slideshow_liquid_slider']['dynamictabs_settings']['panelTitleSelector'] = array(
    '#type' => 'textfield',
    '#title' => t('Panel Title Selector'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamictabs_settings']['panelTitleSelector'],
    '#description' => t('This determines which text to use for each tab name.'),
  );

  // Dynamic Arrows Settings
  $form['views_slideshow_liquid_slider']['dynamicarrows_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Dynamic Arrows'),
    '#weight' => 4,
    '#collapsible' => TRUE,
    '#collapsed' => FALSE,
    '#description' => t('Arrows does not really works at the moment. But if you need them, you can patch the `jquery.liquid-slider.js` in the `libraries` to remove all the `Fade` or `Ease` functions on the Arrows... it is works for me.<br>More information: <a href="http://drupal.org/node/1976142">#1976142</a>'),
  );
  $form['views_slideshow_liquid_slider']['dynamicarrows_settings']['dynamicArrows'] = array(
    '#type' => 'checkbox',
    '#title' => t('Sets whether the arrows will be dynamically created or not.'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamicarrows_settings']['dynamicArrows'],
  );
/*  $form['views_slideshow_liquid_slider']['dynamicarrows_settings']['hoverArrows'] = array(
    '#type' => 'checkbox',
    '#title' => t('If false, the arrows will always display.'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['dynamicarrows_settings']['hoverArrows'],
  );
*/

  // Responsive Settings
  $form['views_slideshow_liquid_slider']['responsive_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Responsive Settings'),
    '#weight' => 5, 
    '#collapsible' => TRUE, 
    '#collapsed' => FALSE,
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['responsive'] = array(
    '#type' => 'checkbox',
    '#title' => t('Responsive'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['responsive'],
    '#description' => t('You can turn the Liquid Slider into a Coda Slider by setting this to false.'),    
  );  
  $form['views_slideshow_liquid_slider']['responsive_settings']['mobileNavigation'] = array(
    '#type' => 'checkbox',
    '#title' => t('Mobile Navigation'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['mobileNavigation'],
    '#description' => t('You can disable the mobile navigation here and instead style the tabs manually.'),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['mobileNavDefaultText'] = array(
    '#type' => 'textfield',
    '#title' => t('Mobile Nav Default Text'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['mobileNavDefaultText'],
    '#description' => t('Set the text to display when using mobile navigation. Use null to disable.'),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['mobileUIThreshold'] = array(
    '#type' => 'textfield',
    '#title' => t('Mobile UI Threshold'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['mobileUIThreshold'],
    '#description' => t('Set a specific width to switch over to mobile navigation. Otherwise it will switch when the width of the tabs exceed the screen width.'),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['hideArrowsWhenMobile'] = array(
    '#type' => 'checkbox',
    '#title' => t('Hide Arrows When Mobile'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['hideArrowsWhenMobile'],
    '#description' => t('Determine whether the arrows should show on mobile devices (when the mobile navigation threshold is exceeded).'),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['hideArrowsThreshold'] = array(
    '#type' => 'textfield',
    '#title' => t('Hide Arrows Threshold'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['hideArrowsThreshold'],
   // '#description' => t(''),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['useCSSMaxWidth'] = array(
    '#type' => 'textfield',
    '#title' => t('Use CSS Max Width'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['useCSSMaxWidth'],
    '#description' => t('Use this as a max width to use CSS transitions. CSS transitions will work on all browsers that support it; however, continuous sliding is disabled, and jQuery animations tend to work better on some browsers/systems (i.e. mine).'),
  );
  $form['views_slideshow_liquid_slider']['responsive_settings']['swipe'] = array(
    '#type' => 'checkbox',
    '#title' => t('Swipe'),
    '#default_value' => $view->options['views_slideshow_liquid_slider']['responsive_settings']['swipe'],
    '#description' => t('If you want to disable swipe events, set this to false.'),
  );

}

/**
 * Form validation callback for the slideshow settings.
 */
function views_slideshow_liquid_slider_views_slideshow_options_form_validate(&$form, &$form_state, &$view) {
  $values = $form_state['values']['style_options']['views_slideshow_liquid_slider'];

  if (!is_numeric($values['autoslide_settings']['autoSlideInterval'])) {
    form_error($form['views_slideshow_liquid_slider']['autoslide_settings']['autoSlideInterval'], t('!setting must be numeric!', array('!setting' => 'Duration auto slide')));
  }

  if (!is_numeric($values['autoheightmin'])) {
    form_error($form['views_slideshow_liquid_slider']['autoheightmin'], t('!setting must be numeric!', array('!setting' => 'Auto Height Min')));
  }

  if (!is_numeric($values['responsive_settings']['useCSSMaxWidth'])) {
    form_error($form['views_slideshow_liquid_slider']['responsive_settings']['useCSSMaxWidth'], t('!setting must be numeric!', array('!setting' => 'CSS Max Width')));
  }

  if (!is_numeric($values['responsive_settings']['hideArrowsThreshold'])) {
    form_error($form['views_slideshow_liquid_slider']['responsive_settings']['hideArrowsThreshold'], t('!setting must be numeric!', array('!setting' => 'Hide Arrows Threshold')));
  }

  if (!is_numeric($values['responsive_settings']['mobileUIThreshold'])) {
    form_error($form['views_slideshow_liquid_slider']['responsive_settings']['mobileUIThreshold'], t('!setting must be numeric!', array('!setting' => 'Mobile UI Threshold')));
  }


}

/**
 * Implements hook_views_slideshow_option_definition().
 */
function views_slideshow_liquid_slider_views_slideshow_option_definition() {
  $options['views_slideshow_liquid_slider'] = array(
    'contains' => array(

      'caption_field' => array('none' => 'None'),

      'autoheight_settings' => array(
        'contains' => array(
          'autoHeight' => array('default' => 1),
          'autoHeightMin' => array('default' => 0),
          'autoHeightEaseDuration' => array('default' => 1500),
        ),
      ),

      'autoslide_settings' => array(
        'contains' => array(
          'autoSlide' => array('default' => 0),
          'autoSliderDirection' => array('default' => 'right'),
          'autoSlideInterval' => array('default' => 7000),
          'autoSlideControls' => array('default' => 0),
          'autoSlideStartText' => array('default' => 'Start'),
          'autoSlideStopText' => array('default' => 'Stop'),
          'autoSlideStopWhenClicked' => array('default' => 1),
          'autoSlidePauseOnHover' => array('default' => 1),
        ),
      ),

      'dynamictabs_settings' => array(
        'contains' => array(
          'dynamicTabs' => array('default' => 1),
          'dynamicTabsAlign' => array('default' => 'left'),
          'dynamicTabsPosition' => array('default' => 'top'),
          'panelTitleSelector' => array('default' => 'h2.title'),
        ),
      ),

      'dynamicarrows_settings' => array(
        'contains' => array(
          'dynamicArrows' => array('default' => 0),
          'hoverArrows' => array('default' => 1),
        ),
      ),

      'responsive_settings' => array(
        'contains' => array(
          'responsive' => array('default' => 1),
          'mobileNavigation' => array('default' => 1),
          'mobileNavDefaultText' => array('default' => 'Menu'),
          'mobileUIThreshold' => array('default' => 0),
          'hideArrowsWhenMobile' => array('default' => 1),
          'hideArrowsThreshold' => array('default' => 481),
          'useCSSMaxWidth' => array('default' => 1030),
          'swipe' => array('default' => 1),
        ),
      ),
    ),
  );
  return $options;
}

/**
 * Implements hook_views_slideshow_skin_info().
 */
function views_slideshow_liquid_slider_views_slideshow_skin_info() {
  return array(
    'default' => array(
      'name' => t('Default'),
    ),
  );
}
