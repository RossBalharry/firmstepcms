<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">

  <!-- Modal popup body -->
  <xsl:template name="colchester-map">
	<xsl:param name="address"/>
    <iframe class="map-frame" frameborder="0" scrolling="no" src="https://connect.colchester.gov.uk/connect/firmstepmini.html?search=CO3 3WG CO3 3WG">
	</iframe>
  </xsl:template>

</xsl:stylesheet>