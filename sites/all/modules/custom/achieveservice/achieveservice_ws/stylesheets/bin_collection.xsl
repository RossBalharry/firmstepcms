<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Bin Collections</xsl:variable>


  <xsl:template match="/">
    <response>
      <title>Bin Collection</title>
      <content>
        <div class="bin-widget">
          <div class="bin-widget-icon black"></div>
          <div class="pad-from-image">

            <xsl:choose>
              <xsl:when test="string-length(//feed/collection/collection_day) > 0">
                <h3>Your next bin collection is</h3>
                <div class="bin-widget-date">
                  <xsl:value-of select="//feed/collection/collection_day" />
                </div>
                <div class="bin-widget-address">
                  <xsl:value-of select="//feed/collection/ward" />
                </div>
              </xsl:when>
              <xsl:otherwise>
                <div class="bin-widget not-setup">Sorry, we haven't found bin collection information for your registered address.</div>
              </xsl:otherwise>
            </xsl:choose>



          </div>
        </div>
      </content>
    </response>
  </xsl:template>


</xsl:stylesheet>
