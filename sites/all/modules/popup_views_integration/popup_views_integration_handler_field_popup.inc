<?php

/**
 * @file
 * Contain the integration with views
 * A handler to provide a field for creating a configurable pop-up from 
 * the popup module.
 * @ingroup views_field_handlers
 */

class popup_views_integration_handler_field_popup extends views_handler_field {
  /**
   * Defines the query that should be run. No queries needed in this case.
   */
  function query() {
    $this->ensure_my_table();
    $this->add_additional_fields();
  }

  /**
   * Defines the default values of options.
   */
  function option_definition() {
    $options = parent::option_definition();
    $options['title'] = array('default' => '');
    $options['text'] = array('default' => '');
    $options['effect'] = array('default' => 'default');
    $options['activate'] = array('default' => 'hover');
    $options['path'] = array('default' => '');
    $options['close'] = array('default' => '');
    $options['origin'] = array('default' => 'bottom-right');
    $options['expand'] = array('default' => 'bottom-right');
    $options['expand'] = array('default' => 'bottom-right');
    $options['width'] = array('default' => variable_get('popup-width', ''));
    $options['height'] = array('default' => '');
    $options['style'] = array('default' => variable_get('popup-style', 0));
    $options['height'] = array('default' => '');
    $options['popup_class'] = array('default' => '');
    return $options;
  }

  /**
   * Defines the form options.
   */
  function options_form(&$form, &$form_state) {
    parent::options_form($form, $form_state);

    $form['title'] = array(
      '#type' => 'textarea',
      '#title' => t('Link'),
      '#description' => t('What to display in the trigger link. You may include any HTML but links. You may enter data from this view from the "Replacement patterns".'),
      '#default_value' => $this->options['title'],
    );

    $form['text'] = array(
      '#type' => 'textarea',
      '#title' => t('Text to display'),
      '#description' => t('Text to display inside the popup. You may include HTML. You may enter data from this view from the "Replacement patterns".'),
      '#default_value' => $this->options['text'],
    );

    module_load_include('inc', 'popup', 'includes/popup.util');
    $style_names = array_keys(_popup_styles());
    $style_options = array_combine(
      $style_names,
      $style_names
    );
    array_unshift($style_options, t('No style'));

    $form['style'] = array(
      '#type' => 'select',
      '#title' => t('Add close button'),
      '#default_value' => $this->options['style'],
      '#options' => $style_options,
      '#description' => t('Preview may not take the defined style'),
    );

    $form['activate'] = array(
      '#type' => 'select',
      '#title' => t('Activation mode'),
      '#default_value' => $this->options['activate'],
      '#options' => array('hover' => t('On hover'), 'click' => t('On click')),
    );

    $form['path'] = array(
      '#type' => 'textfield',
      '#title' => t('Path'),
      '#default_value' => $this->options['path'],
      '#description' => t('Specify a path for the href attribute of the a tag. Works only if the popup is triggered through "hover". Should also be set as a fallback if javascript is deactivated in the users browser.'),
    );

    $form['popup_class'] = array(
      '#type' => 'textfield',
      '#title' => t('Extra popup_class for the popup body.'),
      '#default_value' => check_plain($this->options['popup_class']),
    );

    $form['close'] = array(
      '#type' => 'checkbox',
      '#title' => t('Add close button'),
      '#description' => t('<b>Only for <em>On click</em></b> : add a close button.'),
      '#default_value' => $this->options['close'],
    );

    $form['effect'] = array(
      '#type' => 'select',
      '#title' => t('Effect'),
      '#options' => array(
        'default' => t('No effect'),
        'fade' => t('Fade'),
        'slide-down' => t('Slide down'),
        'slide-down-fade' => t('Slide down and fade'),
      ),
      '#default_value' => $this->options['effect'],
    );

    $form['origin'] = array(
      '#type' => 'select',
      '#title' => t('Origin'),
      '#options' => array(
        'top-left' => t('Top left'),
        'top-right' => t('Top right'),
        'bottom-left' => t('Bottom left'),
        'bottom-right' => t('Bottom-right'),
      ),
      '#default_value' => $this->options['origin'],
    );

    $form['expand'] = array(
      '#type' => 'select',
      '#title' => t('Position'),
      '#options' => array(
        'top-left' => t('Top left'),
        'top-right' => t('Top right'),
        'bottom-left' => t('Bottom left'),
        'bottom-right' => t('Bottom-right'),
      ),
      '#default_value' => $this->options['expand'],
    );

    $form['width'] = array(
      '#type' => 'textfield',
      '#title' => t('Width'),
      '#default_value' => $this->options['width'],
    );

    $form['height'] = array(
      '#type' => 'textfield',
      '#title' => t('Height'),
      '#default_value' => $this->options['height'],
    );
  }

  /**
   * Render the trigger field and its linked popup information.
   */
  function render($values) {
    // We need to have multiple unique IDs, one for each record.
    static $i = 0;
    static $link;

    if (!empty($this->options['title']) && !empty($this->options['text'])) {

      $tokens = $this->get_render_tokens($this->options['alter']);
      $attributes = $this->options;
      // Title and text accepts HTML, other must be plain text.
      $attributes['title'] = filter_xss_admin($this->options['title']);
      $attributes['text'] = filter_xss_admin($this->options['text']);
      $attributes['height'] = strip_tags($this->options['height']);
      $attributes['height'] = check_plain($attributes['height']);
      $attributes['width'] = strip_tags($this->options['width']);
      $attributes['width'] = check_plain($attributes['width']);
      $attributes['path'] = strip_tags($this->options['path']);
      $attributes['path'] = check_plain($attributes['path']);
      $attributes['popup_class'] = strip_tags($this->options['popup_class']);
      $attributes['popup_class'] = check_plain($attributes['popup_class']);

      // Filter links (<a> tags) because it breaks the popup.
      $title = strtr($attributes['title'], $tokens);
      $attributes['title'] = preg_replace(array('/<a [^>]+>/i', '</a>'), '', $title);
      $attributes['text'] = strtr($attributes['text'], $tokens);

      // TODO : use $this->['empty'] if empty.
      if (!$attributes['text'] || !$attributes['title']) {
        return;
      }

      $attributes['path'] = strtr($attributes['path'], $tokens);
      if (isset($attributes['popup_class'])) {
        $attributes['popup_class'] = strtr($attributes['popup_class'], $tokens);
      }
      $attributes['height'] = strtr($attributes['height'], $tokens);
      $attributes['width'] = strtr($attributes['width'], $tokens);

      module_load_include('inc', 'popup', 'includes/popup.api');
      return popup($attributes);
    }
    else {
      return;
    }
  }
}
