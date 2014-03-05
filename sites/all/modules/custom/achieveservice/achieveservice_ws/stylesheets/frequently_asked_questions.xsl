<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">

  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Frequently Asked Questions</xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="faqs-header">Frequently Asked Questions</h1></title>
      <content>
        <xsl:for-each select="/items/item">
          <div class="faq">
            <div class="question">
	            <div class="question-icon collapsed"></div>
              <xsl:value-of select="question"/>
            </div>
            <div class="answer">
              <xsl:value-of select="answer" disable-output-escaping="yes" />
            </div>
          </div>
        </xsl:for-each>
      </content>
    </response>
  </xsl:template>
  
</xsl:stylesheet>
