<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Benefits Summary</xsl:variable>
  <xsl:variable name="more_details_path">firmstep/selfservice/accounts/benefits/</xsl:variable>
  
  <xsl:template match="/">
    <response>
      <title>Benefits</title>
      <content>
        <xsl:apply-templates select="feed/ServicesResponseEnvelope/claims" />
        <div class='clear'></div>
        <xsl:call-template name="links" />
      </content>
    </response>
  </xsl:template>
  
  <!-- Related links -->
  <xsl:template name="links" >
    <xsl:for-each select="/feed/ServicesResponseEnvelope/claims[1]/links">
      <div class="links">
        <xsl:choose>
          <xsl:when test="count(/feed/ServicesResponseEnvelope/claims/claim/reference) > 0">
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="$more_details_path" />
              </xsl:attribute>
              Full Benefits details
            </a>
          </xsl:when>
          <xsl:otherwise>
            <!-- Output non-internal form links -->
            <xsl:for-each select="link[(not(@rel) or @rel!='internal') and @type='form']">
              <xsl:apply-templates select="." />
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="link[@type='form']">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="php:function('base_path')" />default.aspx/<xsl:value-of select="@href" />&amp;FinishURL=/../<xsl:value-of select="$return_path" />
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@title" />
      </xsl:attribute>
      <xsl:value-of select="@title" />
    </a>
  </xsl:template>
  
  <!-- Main -->
  <xsl:template match="claims">
    <xsl:choose>
      <xsl:when test="count(claim/reference) = 0">
        <div class="no-account">
        You currently don't have any benefits registered.
      </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="claim" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="claim">
    <xsl:call-template name="expandable">
      <xsl:with-param name="title">
        <xsl:value-of select="''"/>
        <xsl:value-of select="concat('Ref ', reference)"/>
      </xsl:with-param>
      <xsl:with-param name="expanded" select="position() = 1"/>
      <xsl:with-param name="body">
        <div class="claim">
          <span class="claimant resident"><xsl:value-of select="claimantName" /></span>
          <div class="claim-details">
            <div class="claim-reference">
              <span class="label">Reference </span>
              <a href="/firmstep/selfservice/accounts/benefits"><xsl:value-of select="reference" /></a>
            </div>      
            <xsl:apply-templates select="benefits/benefit" />
          </div>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Benefits -->
  <xsl:template match="benefit">
    <div class="benefit">
      <span class='label'>Weekly <xsl:value-of select="type" /> </span>
      <xsl:call-template name="money"><xsl:with-param name="amount" select="currWeeklyAmount" /></xsl:call-template>
    </div>
  </xsl:template>
</xsl:stylesheet>
