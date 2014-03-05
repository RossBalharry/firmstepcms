<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:param name="uid" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Cross References</xsl:variable>
  
  <xsl:variable name="accounts_path">firmstep/selfservice/accounts/</xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="crossref-header">Cross Refs</h1></title>
      <content>
        <div class="crossrefs-wrapper">
          <xsl:choose>
            <xsl:when test="$uid = 0">
              <div class="no-accounts">Please login or create an account in order to access council services.</div>
            </xsl:when>
            <xsl:otherwise>
              <ul> 
                <xsl:for-each select="/feed">
                  <xsl:apply-templates select="reference" />
                </xsl:for-each>
              </ul>
              <div class="crossref-footer">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="concat(php:function('base_path'), $accounts_path)" />
                  </xsl:attribute>
                  More Details
                </a>
              </div>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <div class='clear'></div>
      </content>
    </response>
  </xsl:template>
  
  <xsl:template match="reference">
    
    
    <li class="crossref ref{machine_name} clearfix">
    
    <xsl:choose>
      <xsl:when test="string-length(cross_reference) > 0">
        <div class="is-setup label"><xsl:value-of select="title" /></div>
        <div class="cross_ref">
          <a title="View more details">
            <xsl:attribute name="href">
              <xsl:value-of select="concat(php:function('base_path'), $accounts_path, machine_name)" />
            </xsl:attribute>
            <xsl:value-of select="cross_reference" />
          </a>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="not-setup label"><xsl:value-of select="title" /> has not been set up. </div>
      </xsl:otherwise>
    </xsl:choose>
    
    
    </li>
  </xsl:template>
  
</xsl:stylesheet>
