addArrows:function(g){var f=this,h=(f.options.dynamicArrowsGraphical)?"-arrow ":" ";(f.$sliderWrap).addClass("arrows");if(f.options.dynamicArrowsGraphical){f.options.dynamicArrowLeftText="";f.options.dynamicArrowRightText=""}(f.$sliderId).before('<div class="ls-nav-left'+h+(g||"")+'"><a href="#">'+f.options.dynamicArrowLeftText+"</a></div>");(f.$sliderId).after('<div class="ls-nav-right'+h+(g||"")+'"><a href="#">'+f.options.dynamicArrowRightText+"</a></div>");f.leftArrow=d(f.sliderId+"-wrapper [class^=ls-nav-left]").css("visibility","hidden").addClass("ls-hidden");f.rightArrow=d(f.sliderId+"-wrapper [class^=ls-nav-right]").css("visibility","hidden").addClass("ls-hidden");if(!f.options.hoverArrows){f.hideShowArrows(e,true,true,false)}},hideShowArrows:function(k,h,m,l){var i=this,j=(typeof k!=="undefined")?k:i.options.fadeOutDuration,f=(typeof k!=="undefined")?k:i.options.fadeInDuration,g=h?"visible":"hidden";if(!m&&(l||(i.sanatizeNumber(i.nextPanel)===1))){i.leftArrow.stop().fadeTo(j,0,function(){d(this).css("visibility",g).addClass("ls-hidden")})}else{if(m||i.leftArrow.hasClass("ls-hidden")){i.leftArrow.stop().css("visibility","visible").fadeTo(f,1).removeClass("ls-hidden")}}if(!m&&(l||(i.sanatizeNumber(i.nextPanel)===i.panelCount))){i.rightArrow.stop().fadeTo(j,0,function(){d(this).css("visibility",g).addClass("ls-hidden")})}else{if(m||i.rightArrow.hasClass("ls-hidden")){i.rightArrow.stop().css("visibility","visible").fadeTo(f,1).removeClass("ls-hidden")}}},registerArrows:function(){var f=this;d((f.$sliderWrap).find("[class^=ls-nav-]")).on("click",function(){f.setNextPanel(d(this).attr("class").split(" ")[0].split("-")[2])})},