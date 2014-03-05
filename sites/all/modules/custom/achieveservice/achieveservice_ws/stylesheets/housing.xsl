<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <!--<xsl:param name="return_path" />-->
  <xsl:variable name="return_path">firmstep/selfservice/accounts/housing</xsl:variable>
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Housing</xsl:variable>
  <xsl:variable name="static-text">
    <p>
      If you are in arrears or have questions about your rent or tenancy, please contact our Customer Service Team
      on (01206) 282514 or email us at <a href="mailto:cbh@colchester.gov.uk">info@cbhomes.org.uk</a>
    </p>
  </xsl:variable>
  <xsl:variable name="static-text-2">
    <p class="disclaimer">
      Please be aware that payments made in the last 4 days may not appear on your statement.
    </p>
  </xsl:variable>
  <xsl:variable name="current-balance-help-text">
    This includes any arrears balance and your current week's rent.
  </xsl:variable>
  <xsl:variable name="arrears-balance-help-text">
    This is the balance outstanding last week, and does not include your current week's rent.
  </xsl:variable>
  <xsl:variable name="sub-accounts-balance-help-text">
    This amount is held separately from your current or arrears balance.
  </xsl:variable>
  <xsl:variable name="total-balance-help-text">
    This is the total amount outstanding, including sub-accounts.
  </xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="housing-header">Housing</h1></title>
      <content>
        <xsl:choose>
          <xsl:when test="string-length(/feed/ServicesResponseEnvelope/HsgAccountView/tenancyDetails/propertyReference) = 0">
            <xsl:call-template name="no-housing-details" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="/feed/ServicesResponseEnvelope/HsgAccountView">
              <xsl:variable name="accountRow" select="."/>
              <xsl:call-template name="expandable">
                <xsl:with-param name='expanded' select='position() = 1 and count(/feed/ServicesResponseEnvelope/HsgAccountView) = 1'/>
                <xsl:with-param name="title">
                  <xsl:value-of select="concat('Property Ref ', tenancyDetails/propertyReference, ': ', tenancyDetails/address/address1)"/>
                  <!-- Remove display of balance for Colchester
	              <xsl:call-template name='money'>
                    <xsl:with-param name='amount' select='balances/currentBalance'/>
                  </xsl:call-template>
                  -->
                </xsl:with-param>
                <xsl:with-param name="body">
                  <xsl:apply-templates select="$accountRow"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <div class='clear'></div>
        <div class="global-links">
          <xsl:apply-templates select="/feed/ServicesResponseEnvelope/HsgAccountView[1]/links/link[(not(@rel) or @rel!='internal') and (@type='form' or @type='external')]"/>
        </div>
      </content>
    </response>
  </xsl:template>
  
  <xsl:template name="no-housing-details">
    <div class="no-housing-details">
      You currently don't have a housing account registered.
    </div>
  </xsl:template>
  
  <xsl:template match="Tenants">
    <div class='joint-tenants'>
      <span class='label'>Joint tenants: </span>
      <xsl:call-template name="join">
        <xsl:with-param name="list" select="jointTenantName"/>
        <xsl:with-param name="no-values-message" select="'(None)'"/>
      </xsl:call-template>
    </div>
  </xsl:template>
  
  <xsl:template match="HsgAccountView">
    <xsl:apply-templates select="tenancyDetails"/>
    <xsl:apply-templates select="balances"/>
    <div class='static-text'>
      <xsl:copy-of select="$static-text"/>
    </div>
    <xsl:apply-templates select="HsgChargeDetails"/>
    <xsl:apply-templates select="tenancyTransactions">
	  	<xsl:with-param name="currentBalance" select="balances/currentBalance"/>
		</xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tenancyDetails">
    <div class='tenancy-details'>
      <!-- Lead Tenant Name -->
      <div class='lead-tenant'>
        <xsl:value-of select="Tenants/leadTenantName"/>
        <span class='label'> (Lead Tenant)</span>
      </div>
      <!-- Address -->
      <xsl:apply-templates select="address" />
      <!-- Reference numbers -->
      <div class='reference-numbers'>
        <!-- Property reference -->
        <div class="property-reference">
          <span class="label">Property reference: </span>
          <xsl:value-of select="propertyReference"/>
        </div>
        <!-- Swipe card number/Payment reference -->
        <div class="swipe-card-no">
          <span class="label">Payment reference: </span>
          <xsl:value-of select="swipeCardNo"/>
        </div>
      </div>
      <!-- Tenants -->
      <xsl:apply-templates select="Tenants"/>
      <!-- Other Occupants -->
      <div class='other-occupants'>
        <span class='label'>Other occupants: </span>
        <xsl:call-template name="join">
          <xsl:with-param name="list" select="otherOccupants/otherOccupantName"/>
          <xsl:with-param name="no-values-message" select="'(None)'"/>
        </xsl:call-template>
      </div>
      <!-- Tenancy info -->
      <div class="tenancy-info">
        <!-- Tenancy type -->
        <div class="tenancy-type">
          <span class='label'>Tenancy type: </span>
          <xsl:value-of select="tenancyTypeDesc"/>
        </div>
        <!-- Payment method -->
        <div class="payment-method">
          <span class="label">Payment method: </span>
          <xsl:value-of select="paymentMethodDesc"/>
        </div>
        <!-- Start date -->
        <div class="tenancy-start-date">
          <span class='label'>Tenancy start date: </span>
          <xsl:call-template name="date"><xsl:with-param name="date" select="tenancyStartDate"/></xsl:call-template>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="balances">
    <div class="balance-amounts">
      <!-- Current balance -->
      <div class='current-balance'>
        <span class='label'>Current balance: </span>
        <xsl:call-template name="money">
          <xsl:with-param name="C-or-D" select="true()"/>
          <xsl:with-param name="amount" select="currentBalance"/>
        </xsl:call-template>
        <xsl:call-template name="help-message">
          <xsl:with-param name="subject">Current Balance</xsl:with-param>
          <xsl:with-param name="text" select="$current-balance-help-text"/>
        </xsl:call-template>
      </div>
      <!-- Arrears balance -->
      <div class='arrears-balance'>
        <span class='label'>Arrears balance: </span>
        <xsl:call-template name="money">
          <xsl:with-param name="C-or-D" select="true()"/>
          <xsl:with-param name="amount" select="arrearsBalance"/>
        </xsl:call-template>
        <xsl:call-template name="help-message">
          <xsl:with-param name="subject">Arrears Balance</xsl:with-param>
          <xsl:with-param name="text" select="$arrears-balance-help-text"/>
        </xsl:call-template>
      </div>
      <!-- Sub-accounts -->
      <div class='sub-accounts-balance'>
        <span class='label'>Sub-accounts balance: </span>
        <xsl:call-template name="money">
          <xsl:with-param name="C-or-D" select="true()"/>
          <xsl:with-param name="amount" select="subaccountBalance"/>
        </xsl:call-template>
        <xsl:call-template name="help-message">
          <xsl:with-param name="subject">Sub-Accounts Balance</xsl:with-param>
          <xsl:with-param name="text" select="$sub-accounts-balance-help-text"/>
        </xsl:call-template>
      </div>
      <!-- Total balance -->
      <div class='total-balance'>
        <span class='label'>Total balance: </span>

				<xsl:choose>
					<xsl:when test='currentBalance = ""'>
						<xsl:call-template name="money">
							<xsl:with-param name="C-or-D" select="true()"/>
							<xsl:with-param name="amount" select="(number(subaccountBalance))"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test='subaccountBalance = ""'>
						<xsl:call-template name="money">
							<xsl:with-param name="C-or-D" select="true()"/>
							<xsl:with-param name="amount" select="(number(currentBalance))"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="money">
							<xsl:with-param name="C-or-D" select="true()"/>
							<xsl:with-param name="amount" select="(number(currentBalance)) + (number(subaccountBalance))"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

        <xsl:call-template name="help-message">
          <xsl:with-param name="subject">Total Balance</xsl:with-param>
          <xsl:with-param name="text" select="$total-balance-help-text"/>
        </xsl:call-template>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="tenancyTransactions">
  	<xsl:param name="currentBalance"/>
    <h3>
      <xsl:choose>
        <xsl:when test='ancestor::HsgAccountView/tenancyDetails/rentGroup = "LH"'>
          Service Charge Statement
        </xsl:when>
        <!-- Known others: WK, WM -->
        <xsl:otherwise>
          Rent Statement
        </xsl:otherwise>
      </xsl:choose>
    </h3>
    <div class='static-text'>
      <xsl:copy-of select="$static-text-2"/>
    </div>
      <div style="background-img:none" class="my-info-tables">
      <xsl:for-each select="transactions">
          <xsl:call-template name="expandable">
              <xsl:with-param name="title">
                  <xsl:value-of select="concat('View transactions for: ', accountHeading)"/>
              </xsl:with-param>
              <xsl:with-param name="expanded" select="position() = 1"/>
              <xsl:with-param name="body">
                  <xsl:call-template name="transactions">
                      <xsl:with-param name="currentBalance" select="$currentBalance"/>
                  </xsl:call-template>
              </xsl:with-param>
          </xsl:call-template>
      </xsl:for-each>
    </div>  
  </xsl:template>

    <xsl:template name="transactions">
    	<xsl:param name="currentBalance"/>
        <table style="background-img:none">
            <thead>
                <tr>
                <th colspan="5"><xsl:value-of select="accountHeading"/></th>
                </tr>
                <tr>
                    <th>Date</th>
                    <th>Description</th>
                    <th class="money-value">Charge</th>
                    <th class="money-value">Payment</th>
                    <th class="money-value">Running Total</th>
                </tr>
            </thead>
            <tbody>

                <xsl:choose>
                    <xsl:when test="subAccountNumber = 'R0'">
                        <xsl:call-template name="transactionFromTotal">
                            <xsl:with-param name="total" select="0 - $currentBalance"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="transaction">
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="transactionFromTotal" match="transaction">
        <xsl:param name="subAcctNo"/>
        <xsl:param name="total"/>


        <xsl:variable name="runningBalance" select="$total"/>
        
        <xsl:for-each select="transaction">
            <xsl:variable name="row" select="."/>
            <xsl:variable name="row-number" select="position()"/>
            <xsl:variable name="prev-rows" select="ancestor::transactions/transaction[position() &lt; $row-number]"/>




            <tr>
                <td>
                    <xsl:call-template name="date">
                        <xsl:with-param name="date" select="transactionDate"/>
                    </xsl:call-template>
                </td>
                <td>
                    <xsl:value-of select="transactionDescription"/>
                </td>
                <td class="money-value">
                    <xsl:if test="type = 'D'">
                        <xsl:call-template name="money">
                            <xsl:with-param name="amount" select="transactionAmount"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>
                <td class="money-value">
                    <xsl:if test="type = 'C'">
                        <xsl:call-template name="money">
                            <xsl:with-param name="amount" select="transactionAmount"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>
                <td class="money-value">
                    <xsl:choose>
                        <xsl:when test="$row-number = 1">
                            <b>
                                <xsl:call-template name="runningtotal">
                                    <xsl:with-param name="runningTotal" select="$runningBalance"/>
                                </xsl:call-template>
                            </b>
                        </xsl:when>
                        <xsl:otherwise>


                            <xsl:variable name="prev-row-value"/>
                            <xsl:call-template name="runningtotal">
                                <xsl:with-param name="runningTotal" select="$runningBalance - sum($prev-rows[type='C']/transactionAmount) + sum($prev-rows[type='D']/transactionAmount)"/>
                            </xsl:call-template>
                            <!--
                            <xsl:value-of select="sum($prev-rows[type='C']/transactionAmount)"/>
                            <xsl:value-of select="sum($prev-rows[type='D']/transactionAmount)"/>-->
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
  
  <xsl:template name="transaction" match="transaction">
      <xsl:param name="subAcctNo"/>
    
          <xsl:for-each select="transaction">
          <xsl:variable name="row" select="."/>
          <xsl:variable name="row-number" select="position()"/>
          <xsl:variable name="prev-rows" select="ancestor::transactions/transaction[position() &gt;= $row-number]"/>
     



          <tr>
            <td><xsl:call-template name="date"><xsl:with-param name="date" select="transactionDate"/></xsl:call-template></td>
            <td>
							<xsl:value-of select="transactionDescription"/>
            </td>
            <td class="money-value">
              <xsl:if test="type = 'D'">
                <xsl:call-template name="money"><xsl:with-param name="amount" select="transactionAmount"/></xsl:call-template>
              </xsl:if>
            </td>
            <td class="money-value">
              <xsl:if test="type = 'C'">
                <xsl:call-template name="money"><xsl:with-param name="amount" select="transactionAmount"/></xsl:call-template>
              </xsl:if>
            </td>
            <td class="money-value">
			  <xsl:choose>
				<xsl:when test="$row-number = 1">
					<b>
					  <xsl:call-template name="runningtotal">
                          <xsl:with-param name="runningTotal" select="sum($prev-rows[type='C']/transactionAmount) - sum($prev-rows[type='D']/transactionAmount)"/>
                      </xsl:call-template>
					</b>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:call-template name="runningtotal">
                      <xsl:with-param name="runningTotal" select="sum($prev-rows[type='C']/transactionAmount) - sum($prev-rows[type='D']/transactionAmount)"/>
				  </xsl:call-template>
				</xsl:otherwise>
			  </xsl:choose>
            </td>
          </tr>
        </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="runningtotal">
      <xsl:param name="runningTotal"/>

	  <xsl:choose>
		<xsl:when test="$runningTotal &lt; 0">
		  <xsl:call-template name="money">
			<xsl:with-param name="amount" select="-$runningTotal"/>
		  </xsl:call-template>
		  <xsl:value-of select="' D'"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:call-template name="money">
			<xsl:with-param name="amount" select="$runningTotal"/>
		  </xsl:call-template>
		  <xsl:value-of select="' C'"/>
	   </xsl:otherwise>
	 </xsl:choose>
	 
  </xsl:template>
  
  <xsl:template match="HsgChargeDetails">
    <h3>
      <xsl:choose>
        <xsl:when test="ancestor::HsgAccountView/tenancyDetails/rentGroup = 'LH'">
          Service Charges
        </xsl:when>
        <!-- Known others: WK, WM -->
        <xsl:otherwise>
          Rent and Service Charges
        </xsl:otherwise>
      </xsl:choose>
    </h3>
    <div class='clear'></div>
    <xsl:apply-templates select="chargePeriod"/>
    <div class='clear'></div>
  </xsl:template>
  
  <xsl:template match="chargePeriod">
    <div>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="(position() mod 2) = 1">column1 my-info-tables</xsl:when>
          <xsl:when test="(position() mod 2) = 0">column2 my-info-tables</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <div class="charge-period">
        <h4>
          <xsl:value-of select="rentAccountDesc"/>
        </h4>
        <table class="horizontal">
          <tbody>
            <tr>
              <th>Rent charges</th>
              <td class="money-value">
                <xsl:call-template name='money'>
                  <xsl:with-param name='amount' select='rentCharges'/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <th>Service charges</th>
              <td class="money-value">
                <xsl:call-template name='money'>
                  <xsl:with-param name='amount' select='serviceCharges'/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <th>Total charges</th>
              <td class="money-value">
                <xsl:call-template name='money'>
                  <xsl:with-param name='amount' select='chargesTotal'/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <th>Weekly amount</th>
              <td class="money-value">
                <xsl:call-template name="money">
                  <xsl:with-param name="amount" select="currWeeklyAmount"/>
                </xsl:call-template>
              </td>
            </tr>
            <tr>
              <th>Until</th>
              <td class="money-value">
                <xsl:call-template name="date"><xsl:with-param name="date" select="chargeTo"/></xsl:call-template>
              </td>
            </tr>
          </tbody>
        </table>
        <!--
        <div class='period-dates'>
          <xsl:value-of select="'Until: '"/>
          <span class='to-date'>
            <xsl:call-template name="date"><xsl:with-param name="date" select="chargeTo"/></xsl:call-template>
          </span>
        </div>
        <div class='charges-summary'>
          <div class='rent-charges'>
            <span class='label'>Rent charges: </span>
            <xsl:call-template name='money'><xsl:with-param name='amount' select='rentCharges'/></xsl:call-template>
          </div>
          <div class='service-charges'>
            <span class='label'>Service charges: </span>
            <xsl:call-template name='money'><xsl:with-param name='amount' select='serviceCharges'/></xsl:call-template>
          </div>
          <div class='total-charges'>
            <span class='label'>Total charges: </span>
            <xsl:call-template name='money'><xsl:with-param name='amount' select='chargesTotal'/></xsl:call-template>
          </div>
        </div>
        -->
        <xsl:call-template name="expandable">
          <xsl:with-param name='title'>How this was calculated</xsl:with-param>
          <xsl:with-param name='body'>
            <xsl:apply-templates select="chargesBreakdown"/>
          </xsl:with-param>
        </xsl:call-template>
      </div>
    </div>
  </xsl:template>
  
  <xsl:key name="charges-by-description" match="charge" use="description" />
    
  <xsl:template match="chargesBreakdown">
    <table>
      <thead>
        <tr>
          <th>Item</th>
          <th class="money-value">Amount</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="charge">
          <tr>
            <td><xsl:value-of select="description"/></td>
            <td class="money-value"><xsl:call-template name="money"><xsl:with-param name="amount" select="amount"/></xsl:call-template></td>
          </tr>
        </xsl:for-each>
        <tr class='total-row'>
          <td>Total</td>
          <td class="money-value">
            <xsl:call-template name="money"><xsl:with-param name="amount" select="ancestor::chargePeriod/chargesTotal"/></xsl:call-template>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>
 
</xsl:stylesheet>
