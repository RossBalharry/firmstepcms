<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">

  <!-- Correspondence list -->
  <xsl:template match="correspondence">
    <!-- Incoming and outgoing -->
    <xsl:param name="show_incoming" select="true()" />
    <xsl:param name="show_outgoing" select="false()" />

    <!-- Set up offset and limit -->
    <xsl:param name="offset_param" select="0" />
    <xsl:param name="limit_param" select="0" />
    <xsl:variable name="limit">
      <xsl:if test="$limit_param = 0">
        <xsl:value-of name="limit" select="count(outgoing/item)" />
      </xsl:if>
      <xsl:if test="$limit_param > 0">
        <xsl:value-of name="limit" select="$limit_param" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="offset" select="$offset_param" />
    
    <div class="correspondence">
      <!-- Show outgoing letters if asked for and there are some present -->
      <xsl:if test="$show_outgoing and (count(outgoing/item) &gt; 0)">
        <h3>Sent Correspondence</h3>
        <xsl:call-template name="outgoing-correspondence-table">
          <xsl:with-param name="letters" select="outgoing/item[position() &gt;= $offset and position() &lt;= $limit]" />
        </xsl:call-template>
      </xsl:if>
      <!-- Show incoming letters given same conditions -->
      <xsl:if test="$show_incoming and (count(incoming/item) &gt; 0)">
        <h3>Received Correspondence</h3>
        <xsl:call-template name="incoming-correspondence-table">
          <xsl:with-param name="letters" select="incoming/item[position() &gt;= $offset and position() &lt;= $limit]" />
        </xsl:call-template>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Outgoing correspondence table -->
  <xsl:template name="outgoing-correspondence-table">
    <xsl:param name="letters" />
    <table>
      <thead>
        <tr>
          <th>Date sent</th>
          <th>Title</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$letters">
          <xsl:sort data-type="text" select="sentDate" order="descending" />
          <tr>
            <xsl:attribute name="class">
              <xsl:if test="position() mod 2">odd</xsl:if>
            </xsl:attribute>
            <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(sentDate))" /></td>
            <td><xsl:value-of select="documentDetails/documentDescription" /></td>
            <td>
              <!-- Generate the request copy link if we find the link path -->
              <xsl:if test="//*[@id='correspondence_copy_request']">
                <a>
                  <xsl:attribute name="href">
                    <xsl:variable name="base_path" select="concat(php:function('base_path'), 'default.aspx/')" />
                    <xsl:variable name="form_path" select="//*[@id='correspondence_copy_request']/@href" />
                    <xsl:variable name="doc_id_param" select="concat('doc_id=', documentDetails/documentId)" />
                    <xsl:variable name="doc_title_param" select="concat('doc_title=', documentDetails/documentDescription)" />
                    <xsl:variable name="doc_sent_param" select="concat('date_sent=', sentDate)" />
                    <xsl:variable name="extra_params">HideToolbar=1&amp;ReturnURL=/../<xsl:value-of select="$return_path" /></xsl:variable>
                    <xsl:value-of select="concat($base_path, $form_path, '&amp;', $doc_id_param, '&amp;', $doc_title_param, '&amp;', $doc_sent_param, '&amp;', $extra_params)" />
                  </xsl:attribute>
                  Request copy
                </a>
              </xsl:if>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- Incoming correspondence table -->
  <xsl:template name="incoming-correspondence-table">
    <xsl:param name="letters" />
    <table>
      <thead>
        <tr>
          <th>Date received</th>
          <th>Title</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$letters">
          <xsl:sort data-type="text" select="completedDate" order="descending" />
          <tr>
            <xsl:attribute name="class">
              <xsl:if test="position() mod 2">odd</xsl:if>
            </xsl:attribute>
            <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(completedDate))" /></td>
            <td><xsl:value-of select="documentIdentification/documentDescription" /></td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- Truncated correspondence summary -->
  <xsl:template name="correspondence-summary">
    <xsl:param name="index"/>
    <div class="correspondence">
      <h3>Correspondence History</h3>
      <table>
        <thead>
          <tr>
            <th>Date sent</th>
            <th>Title</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="outgoing/item">
            <xsl:sort data-type="text" select="sentDate" order="descending" />
            <xsl:if test="position() &lt;= 5">
              <tr>
                <xsl:attribute name="class">
                  <xsl:if test="position() mod 2">odd</xsl:if>
                </xsl:attribute>
                <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(sentDate))" /></td>
                <td><xsl:value-of select="documentDetails/documentDescription" /></td>
                <td>
                  <a>
                    <xsl:attribute name="href">
                      <xsl:value-of select="php:function('base_path')" />default.aspx/<xsl:value-of select="//*[@id='correspondence_copy_request']/@href" />&amp;<xsl:value-of select="concat('doc_id=', documentDetails/documentId)" />&amp;<xsl:value-of select="concat('doc_title=', documentDetails/documentDescription)" />&amp;<xsl:value-of select="concat('date_sent=', sentDate)" />&amp;HideToolbar=1&amp;ReturnURL=/../<xsl:value-of select="$return_path" />
                    </xsl:attribute>
                    Request copy
                  </a>
                </td>
              </tr>
            </xsl:if>
          </xsl:for-each>
          <xsl:if test="count(outgoing/item) &gt; 5">
            <tr class="link-row">
              <td colspan="3">
                <a title="Full correspondence history">
                  <xsl:attribute name="href">
                    <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="concat($correspondence_history_path, '?index=', string($index))" />
                  </xsl:attribute>
                  View all <xsl:value-of select="count(outgoing/item)" /> items
                </a>
              </td>
            </tr>
          </xsl:if>
        </tbody>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
