(function($){
	Drupal.behaviors.achieveservice_main = {
		attach: function(context, settings) {
      /**
       * reload results for calendar
       */
	    if (!settings.achieveservice_main_bind) {
	      settings.achieveservice_main_bind = true;
  	  
    	  $('.view-display-id-block_1 tr td.has-events a').live('click',function(event){
          var args = new Object();
          args.href = $(this).attr('href');
          $('.view-display-id-block_1 .attachment .view-calendar').fadeOut('slow', function() {});
          Drupal.behaviors.achieveservice_main.ajax(settings, args, 'ajax_achieveservice_main/calendar/update', 'calendar_update_success', 'calendar_update_error', '.clear-submit');
          event.preventDefault();
          return false;
        });
  
      	/**
      	 * Process request to the server 
      	 */
      	Drupal.behaviors.achieveservice_main.ajax = function(settings, args, path, fn_success, fn_error, loader_element) {
      	  if(typeof(loader_element) !== 'undefined'){
      	    $(loader_element).show();
      	  }
          var request = $.ajax({
            type: "POST",
            url: settings.basePath+path,
            data: args,
            dataType: 'json',
            success: function(result){
              if(result.status) {
                $(document).trigger(fn_success, result); 
              }
              else {
                result.status_code = 200;
                $(document).trigger(fn_error, result); 
              }
              if(typeof(loader_element) !== 'undefined'){
                $(loader_element).hide();
              }
            },
            error: function (xhr, status) {
              var result = new Object();
              result.status = false;
              result.xhr = xhr;
              result.status_code = status;
              $(document).trigger(fn_error, result);
              if(typeof(loader_element) !== 'undefined'){
                $(loader_element).hide();
              }
            }
          });
        };
  
        /**
         * Calendar update success handler
         */
        $(document).bind('calendar_update_success', function(e, result) {  
          $('.view-display-id-block_1 .attachment').hide();
          $('.view-display-id-block_1 .attachment').html(result.content);
          $('.view-display-id-block_1 .attachment').fadeIn('slow', function() {});
        });
      
        /**
         * Calendar update error handler
         */
        $(document).bind('calendar_update_error', function(e, result) { 
          $('.error-message').remove();
          if(result.status_code == 200) {
            $('.view-display-id-block_1 .calendar-calendar').after('<p class="error-message">'+result.message+'</p>');
          }
          else {
            $('.view-display-id-block_1 .calendar-calendar').after('<p class="error-message">'+Drupal.t('Error occured - code @code. Try to submit later.', { '@code': result.status_code })+'</p>');
          }
        });
	    }
    }
  };
})(jQuery);