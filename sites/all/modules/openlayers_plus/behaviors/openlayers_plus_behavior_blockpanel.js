(function ($) {

  Drupal.behaviors['extruders.weight'] = -7;
  Drupal.behaviors['collapsiblock.weight'] = 1;
  Drupal.behaviors['openlayers_plus_behavior_blockpanel.weight'] = -98; 
 
 Drupal.behaviors.extruders = {
    attach : function(context, setting) {
      $(".olControlblockpanel", context).once("extruder-done",function () {
        /*
         * Figure out which blockpanel we are loading, get the settings, initiate
         */

        id = $(this).context.firstElementChild.id;
        
        id = id.substr(8, 100);
        settings = setting.openlayers_plus.blockpanels[id];

        options = {
          positionFixed:false,
          width:285,
          sensibility:800,
          position:settings.position, // left, right, bottom
          flapDim:100,
          textOrientation:"bt", // or "tb" (top-bottom or bottom-top)
          onExtOpen:function(){},
          onExtContentLoad:function(){},
          onExtClose:function(){},  
          hidePanelsOnClose:true,
          textOrientation:"bt",
          autoCloseTime:0, // 0=never
          slideTimer:0, // very fast
          top:200,
          extruderOpacity:1
        };

        $(this).context.firstElementChild.innerHTML = settings.markup;
        $(this).addClass("{title:'" + settings.label + "'}");
        $(this).buildMbExtruder(options);
        if (settings.startstatus == 'open') {
          $(this).openMbExtruder(true);
        }
        // And now set the setting
        $(this).context['options'].slideTimer = settings.slidetimer;
        // Don't propagate click events to the map
        // this doesn't catch events that are below the layer list
       this.mousedown = function(evt) {
          OpenLayers.Event.stop(evt);
        };

      });
    }
  };

  Drupal.behaviors.openlayers_plus_behavior_blockpanel = {
    attach : function(context, setting) {
      var data = $(context).data('openlayers');
      if (data && data.map.behaviors.openlayers_plus_behavior_blockpanel) {
        var ctrl;
        var map = data.openlayers;

        blockpanels = setting.openlayers_plus.blockpanels;
        controls = new Array();
        for (region in blockpanels) {
          panel = new OpenLayers.Control.BlockPanel('top');
          panel.html = blockpanels[region]['markup'];//<div class="text">Reinier and a lot of other info</div>';
          panel.label = blockpanels[region]['label']; //'<a href="http://www.google.com">Open Me int he page</a>';
          panel.position = blockpanels[region]['position'];
          panel.id = "Extruder" + region;
          map.addControl(panel);
        }
      }
    }
  };

})(jQuery);

OpenLayers.Control.BlockPanel = OpenLayers.Class(OpenLayers.Control, {

  html: "",
  label: "",
  position: "",
  id: "",
  
  draw: function() {
    OpenLayers.Control.prototype.draw.apply(this, arguments);

    /*
     * We create the div as an empty div, so as to not trigger any behavior on the content
     * before our own behavior is fired. (e.g. collapsiblock)
     * The html is added inside our behavior.
     */
    this.div.innerHTML = '<div id="' + this.id + '"></div>';
    jQuery(this.div).addClass(this.position);

    return this.div;
  },

  CLASS_NAME: "OpenLayers.Control.blockpanel"
});
