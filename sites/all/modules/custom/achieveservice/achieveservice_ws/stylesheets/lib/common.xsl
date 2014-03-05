<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">

  <!-- Load correspondence stylesheet -->
  <xsl:include href="correspondence.xsl" />

  <!-- Address -->
  <xsl:template match="address">
    <address>
      <xsl:value-of select="address1" /><br />
      <xsl:value-of select="address2" /><br />
      <xsl:if test="address3">
        <xsl:value-of select="address3" /><br />
      </xsl:if>
      <xsl:if test="address4">
        <xsl:value-of select="address4" /><br />
      </xsl:if>
      <xsl:value-of select="postcode" /><br />
    </address>
  </xsl:template>

  <!-- Join function -->
  <xsl:template name="join">
    <xsl:param name="list" />
    <xsl:param name="separator" select="', '" />
    <xsl:param name="no-values-message"/>

    <xsl:choose>
      <xsl:when test="count($list) > 0">
        <xsl:for-each select="$list">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:value-of select="$separator" />
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$no-values-message"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Format date function -->
  <xsl:template name="date">
    <xsl:param name="date" />
    <xsl:param name="format" select="string('normal')" />  <!-- Currently not used -->
    <xsl:value-of select="php:function('achieveservice_ws_format_date', string($date))" />
  </xsl:template>

  <!-- AS form links -->
  <!-- Requires return_path global param to be set -->
  <xsl:template match="link">
    <xsl:param name="extra-params" select="''"/>
    <a class="form-link">
      <xsl:if test="string-length(@target) > 0">
        <xsl:attribute name="target">
          <xsl:value-of select="@target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="href">
        <xsl:choose>
          <xsl:when test="@type = 'form'">
            <xsl:value-of select="php:function('base_path')" />default.aspx/<xsl:value-of select="@href" />&amp;FinishURL=/../<xsl:value-of select="$return_path" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@href"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($extra-params) > 0">
          <xsl:value-of select="concat('&amp;', $extra-params)"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@title" />
      </xsl:attribute>
      <xsl:value-of select="@title" />
    </a>
  </xsl:template>

  <!-- Money format -->
  <xsl:template name="money">
    <xsl:param name="amount" />
    <xsl:param name="C-or-D" select="false()"/>
    <xsl:choose>
      <xsl:when test="string-length($amount) = 0">
        <!--
        <xsl:call-template name="empty-box"/>
        -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$C-or-D">
            <xsl:choose>
              <xsl:when test="$amount &lt;= 0">
                <xsl:value-of select="format-number(-$amount, '£#,##0.00 C')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="format-number($amount, '£#,##0.00 D')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-number($amount, '£#,##0.00')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Class attribute -->
  <xsl:template name="class-attr">
    <xsl:param name="class-names" />
    <xsl:if test="normalize-space($class-names) != ''">
      <xsl:attribute name="class"><xsl:value-of select="normalize-space($class-names)" /></xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <!-- Expandable section -->
  <xsl:template name="expandable">
    <xsl:param name="title">Click to expand/collapse</xsl:param>
    <xsl:param name="body" />
    <xsl:param name="expanded" select="false()" />
    
    <fieldset>
      <xsl:call-template name="class-attr">
        <xsl:with-param name="class-names">
          <xsl:if test="true()"> collapsible </xsl:if>
          <xsl:if test="not($expanded)"> collapsed </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <legend><span class="fieldset-legend"><xsl:copy-of select="$title"/></span></legend>
      <div class='fieldset-wrapper ct-fieldset-content clearfix'>
        <xsl:copy-of select="$body"/>
      </div>
    </fieldset>
  </xsl:template>
  
  <!-- Modal popup body -->
  <xsl:template name="create-modal">
    <xsl:param name="id"/>
    <xsl:param name="body"/>
    <div class='simplemodal-content' id='{$id}'>
      <xsl:copy-of select='$body'/>
    </div>
  </xsl:template>
  
  <!-- Output link to show modal -->
  <xsl:template name="modal-link">
    <xsl:param name="id"/>
    <xsl:param name="text"/>
    <a href="#">
      <xsl:attribute name="onclick">jQuery("#<xsl:value-of select="$id"/>").modal({overlayClose:true, opacity:75});return false;</xsl:attribute>
      <xsl:copy-of select="$text"/>
    </a>
  </xsl:template>
  
  <!-- Contents of an empty box -->
  <xsl:template name="empty-box">
    <span class='no-value'>(n/a)</span>
  </xsl:template>
  
  <!-- Help text -->
  <xsl:template name="help-message">
    <xsl:param name="text"/>
    <xsl:param name="subject"/>
    <a href="#" title="{$text}" class="help-message">
      <xsl:attribute name="onclick">jQuery('.help-popup', this).modal({overlayClose:true, opacity:75});return false;</xsl:attribute>
      What is this?
      <div class='help-popup' style='display:none;'><b><xsl:copy-of select="$subject"/>: </b><xsl:copy-of select="$text"/></div>
    </a>
  </xsl:template>
</xsl:stylesheet>
