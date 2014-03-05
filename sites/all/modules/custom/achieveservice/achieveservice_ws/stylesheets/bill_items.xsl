<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" version="1.0">
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Council Bill Items</xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="bill-transactions-header">Bill Transactions</h1></title>
      <content>
        <xsl:apply-templates select="/feed/ServicesResponseEnvelope/billinfo" />
      </content>
    </response>
  </xsl:template>
  
  <xsl:template match="billinfo">
    <div class="bill-details">
      <div class="bill-header-section">
        <div class="account-id">
          <span class="label">Account reference: </span><xsl:value-of select="accountid" />
        </div>
        <div class="bill-number">
          <span class="label">Bill number: </span><xsl:value-of select="billno" />
        </div>
      </div>
	  <h2 class="clearfix bills-title">Bill Transaction Summary</h2>
	  <div class="summary-values">
	    <table class="horizontal">
	      <xsl:for-each select="summaryValues/item">
	        <tr>
		      <th><xsl:value-of select="description" />:</th>
		      <td><xsl:call-template name="money"><xsl:with-param name="amount" select="value"/></xsl:call-template></td>
	        </tr>
	      </xsl:for-each>
		  <tr class="account-balance">
			<th>
              <span class="label">Balance: </span>
			</th>
			<td>
              <xsl:call-template name="money"><xsl:with-param name="amount" select="balance" /></xsl:call-template>
			</td>
	      </tr>
	    </table>
	  </div>
      <div class="dates">
        From <xsl:call-template name="date"><xsl:with-param name="date" select="fromDate" /></xsl:call-template>
        to <xsl:call-template name="date"><xsl:with-param name="date" select="toDate" /></xsl:call-template>.
        Issued <xsl:call-template name="date"><xsl:with-param name="date" select="issued" /></xsl:call-template>
      </div>
    </div>
    <div class="transactions">
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Charge</th>
            <th>Payment</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="lineitem">
            <xsl:sort data-type="number" select="sequenceNo" order="descending" />
			<xsl:variable name="negative" select="amount &lt; 0"/>
            <tr>
			  <xsl:variable name="class">
                <xsl:if test="position() mod 2"> odd </xsl:if>
				<xsl:if test="$negative"> payment </xsl:if>
				<xsl:if test="not($negative)"> charge </xsl:if>
			  </xsl:variable>
			  <xsl:if test="normalize-space($class) != ''">
				  <xsl:attribute name="class">
					<xsl:value-of select="normalize-space($class)"/>
				  </xsl:attribute>
			  </xsl:if>
              <td><xsl:call-template name="date"><xsl:with-param name="date" select="posted" /></xsl:call-template></td>
			  <xsl:if test="$negative"><td></td></xsl:if>
              <td>
			    <span class='money-amount'>
					<xsl:call-template name="money"><xsl:with-param name="amount" select="amount" /></xsl:call-template>
				</span>
			  </td>
			  <xsl:if test="not($negative)"><td></td></xsl:if>
              <td><xsl:value-of select="description" /></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
