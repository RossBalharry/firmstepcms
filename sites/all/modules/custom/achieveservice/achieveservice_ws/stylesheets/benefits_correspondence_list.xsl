<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Benefits Correspondence List</xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="benefits-correspondence-header">Benefits Correspondence History</h1></title>
      <content>
        <xsl:apply-templates select="/feed/ServicesResponseEnvelope/claims/correspondence">
          <xsl:with-param name="show_incoming" select="true()"/>
          <xsl:with-param name="show_outgoing" select="true()"/>
        </xsl:apply-templates>
      </content>
    </response>
  </xsl:template>
</xsl:stylesheet>
