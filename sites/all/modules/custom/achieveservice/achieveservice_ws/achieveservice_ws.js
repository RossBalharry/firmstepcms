jQuery(function () {
    if (Drupal.settings.AchieveServiceWS) {

      // For each AchieveService Web Service block call it's path and update
      // the containing block with the returned title and content.
      jQuery.each(Drupal.settings.AchieveServiceWS.blocks, function(i, block) {
        jQuery.ajax({
          url: block.path,
          data: block.params,
          dataType: 'json',
          success: function(data, textStatus, xhr) {
            var container = jQuery('#'+block.container);
            if(data.title!='none' && data.title!='') container.parents('div.panel-pane:first').find('h2').html(data.title);
            container.html(data.content);
            // Mike - 03/02/11
            // We need to add the address to the url of the map iframe
	          jQuery.fn.exists = function(){return this.length>0;}



	          if (false && jQuery('#my_cases_small-container').exists()) {
		          var case_number = jQuery('#my_cases_small-container > .my-case').size(), case_limit = 3, case_limiter = 0, hidden_items = false, hidden_count = 0;
		          if (!jQuery('.cb-hidder-show').exists()) {
			          jQuery('#my_cases_small-container > .my-case').each(function(){
			                  case_limiter++;
			                  if (case_limit<case_limiter){
						          jQuery(this).addClass('cb-hidder').hide();
			                      hidden_items = true;
			                      hidden_count++;
			                  }
			          });

			          if(hidden_items){
				          jQuery('#my_cases_small-container').append('<div class="cb-hidder-show">Show More ('+hidden_count+')</div>');
				          jQuery('.cb-hidder-show').click(function(){
					          jQuery('.cb-hidder').fadeIn(300);
					          jQuery(this).hide();
			              });
				          jQuery('.cb-hidder-show').hover(function(){
					          jQuery(this).addClass('hover');
				          },function(){
					          jQuery(this).removeClass('hover');
				          });
			          }
		          }
	          }
          },
          error: function(xhr, status, exception) {
            var container = jQuery('#'+block.container);
            container.html('Sorry, there was an error with your request.');
          }
        });
      });
  }
});
