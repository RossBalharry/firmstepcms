This module implements the integration of the Popup module with Views.

It provides a Views global field that can reuse the other Views fields.
It will be output a link that will trigger a popup.

A similar system exists for Lightbox or Colorbox modules and this module has
been inspired by lightbox integration. Popup is different from these two modules 
because it aims at creating internal tooltype-style popups and not a global one.

INSTALLATION

Install the module as usual. The module requires Views and Popup to be installed

USAGE

Under "Global" tag, there is a new field called Popup that you can add in any 
view.

Use token replacements from previous lines in the title and popup textareas.

CUSTOMIZATIONS

-  Display on hover or on click and add or not a close button for onclick event.
-  Defining the effetct (no, slide, fade).
-  Define the style of the popup
-  Height / width
-  Position (top left, top right, bottom left, bottom right).
