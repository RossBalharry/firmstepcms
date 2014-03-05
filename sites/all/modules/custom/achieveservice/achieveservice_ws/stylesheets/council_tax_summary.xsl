<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:param name="return_path" />
  <xsl:variable name="description">Council Tax Summary</xsl:variable>
  <xsl:variable name="more_details_path">firmstep/selfservice/accounts/tax/</xsl:variable>

  <xsl:template match="/">
    <response>
      <title>Council Tax</title>
      <content>
        <xsl:choose>
          <xsl:when test="count(/feed/ServicesResponseEnvelope/CTaxDetails/property/*) = 0">
            <xsl:call-template name="no-account" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="/feed/ServicesResponseEnvelope/CTaxDetails" />
          </xsl:otherwise>
        </xsl:choose>
      </content>
    </response>
  </xsl:template>
  
  <xsl:template name="no-account">
    <div class="no-account">
      You currently don't have a council tax account registered.
      <div class="links">
        <xsl:apply-templates select="/feed/ServicesResponseEnvelope/CTaxDetails[1]/links/link" />
      </div>
	</div>
  </xsl:template>

  <xsl:template match="/feed/ServicesResponseEnvelope/CTaxDetails">
    <xsl:call-template name="expandable">
      <xsl:with-param name="title" select="''"/>
      <xsl:with-param name="title" select="concat('Account ', accountId, ': ', property/address/address1)"/>
      <xsl:with-param name="expanded" select="position() = 1"/>
      <xsl:with-param name="body">
        <xsl:apply-templates select="property" />
        <div class="account-id">
          <span class="label">Account Number </span>
          <a href="/firmstep/selfservice/accounts/tax"><xsl:value-of select="accountId" /></a>
        </div>
        <div class="liable-people">
          <span class="label">All liable people: </span>
          <ul>
            <xsl:for-each select="property/residents/resident">
              <li>
                  <xsl:value-of select="name" />
              </li>
            </xsl:for-each>
          </ul>
        </div>
        <div class="account-balance">
          <span class="label">Account Balance </span>
          <xsl:call-template name="money"><xsl:with-param name="amount" select="accountBalance"/></xsl:call-template>
        </div>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="position()=last()">
      <div class="links">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="$more_details_path" />
          </xsl:attribute>
          Full Council Tax details
        </a>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- Related links -->
  <xsl:template match="links">
    <div class="links">
      <!-- Output non-internal form links -->
      <xsl:for-each select="link[(not(@rel) or @rel!='internal') and @type='form']">
        <xsl:apply-templates select="." />
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="property">
    <div class="property">
      <span class="resident">
        <xsl:call-template name="join">
          <xsl:with-param name="list" select="residents/resident/name" />
          <xsl:with-param name="separator" select="', '" />
        </xsl:call-template>
      </span>
      <xsl:apply-templates select="address" />
    </div>
  </xsl:template>
</xsl:stylesheet>
