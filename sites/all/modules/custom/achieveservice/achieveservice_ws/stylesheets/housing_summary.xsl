<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Housing Summary</xsl:variable>
  <xsl:variable name="more_details_path">firmstep/selfservice/accounts/housing/</xsl:variable>
  <xsl:variable name="register_account_path">default.aspx/RenderForm/?F.Name=raiEugYemwi&amp;FinishURL=/../myaccount/</xsl:variable>
  
  <xsl:template match="/">
    <response>
      <title>Housing</title>
      <content>
        <xsl:choose>
          <xsl:when test="feed/ServicesResponseEnvelope/HsgSummaryView/tenancyDetails/propertyReference">
            <xsl:for-each select="feed/ServicesResponseEnvelope/HsgSummaryView">
              <xsl:call-template name="expandable">
                <xsl:with-param name="title">
                  <xsl:value-of select="concat('Housing Number: ', tenancyDetails/propertyReference, ' - ',
tenancyDetails/address/address1)"/>
                  <xsl:value-of select="''"/>
                </xsl:with-param>
                <xsl:with-param name="expanded" select="position() = 1"/>
                <xsl:with-param name="body">
                  <div class='housing-summary'>
                    <div class='property-ref'>
                      <span class='label'>Account Number </span>
                      <a href="/firmstep/selfservice/accounts/housing"><xsl:value-of select="tenancyDetails/swipecard"/></a>
                    </div>
                    <div class='current-balance'>
                      <span class='label'>Current balance </span>
                      <xsl:call-template name='money'>
                        <xsl:with-param name='C-or-D' select='true()'/>
                        <xsl:with-param name='amount' select='tenancyDetails/currentBalance'/>
                      </xsl:call-template>
                    </div>
                  </div>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:for-each>
            <div class="clear"></div>
            <div class="links">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="$more_details_path" />
                </xsl:attribute>
                Full Housing Details
              </a>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="no-account">
            You currently don't have a housing account registered.
            <div class="clear"></div>
            <div class="links">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="$register_account_path"/>
                </xsl:attribute>
                Register an Account
              </a>
            </div>
          </div>
          </xsl:otherwise>
        </xsl:choose>
        <div class="clear"></div>
      </content>
    </response>
  </xsl:template>
  
</xsl:stylesheet>
