<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Council Tax</xsl:variable>
  <xsl:variable name="bill_detail_path">firmstep/selfservice/accounts/bills/</xsl:variable>
  <xsl:variable name="correspondence_history_path">firmstep/selfservice/accounts/correspondence/</xsl:variable>
  <xsl:variable name="payment_form_name">eM16uCYF4tV</xsl:variable>
  <xsl:variable name="debt-contact-email">corporate.debt@colchester.gov.uk</xsl:variable>
  <xsl:variable name="debt-contact-phone">01206 505 339/01206 505 338/01206 508 801</xsl:variable>
  <xsl:variable name="court-contact-email">corporate.debt@colchester.gov.uk</xsl:variable>
  <xsl:variable name="court-contact-phone">01206 506 573</xsl:variable>
  <xsl:variable name="form-index-param">index</xsl:variable>

  <xsl:template match="/">
    <response>
      <title><h1 id="council-tax-header">Council Tax</h1></title>
      <content>
        <xsl:choose>
          <xsl:when test="count(/feed/ServicesResponseEnvelope/CTax/property/*) = 0">
            You currently don't have a council tax account registered.
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="/feed/ServicesResponseEnvelope/CTax" />
          </xsl:otherwise>
        </xsl:choose>
        <div class='clear'></div>
        <div class="global-links">
          <xsl:for-each select="/feed/ServicesResponseEnvelope/CTax[1]/links/link[@scope='global']">
            <xsl:apply-templates select="." />
          </xsl:for-each>
        </div>
      </content>
    </response>
  </xsl:template>

  <!-- Main -->
  <xsl:template match="/feed/ServicesResponseEnvelope/CTax">
    <xsl:call-template name="expandable">
      <xsl:with-param name="title" select="concat('Account ', accountId, ': ', property/address/address1)"/>
      <xsl:with-param name="expanded" select="position() = 1 and count(/feed/ServicesResponseEnvelope/CTax)=1"/>
      <xsl:with-param name="body">
	      <div class="global-links">
                <xsl:call-template name="links" />
	      </div>
        <xsl:call-template name="ctax-record"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="ctax-record">
    <xsl:variable name="CTax_Index" select="position()"/>
    <!-- Only try to display data if there is an account ID -->
    <xsl:if test="string(accountId)">
      <div class="account-wrapper">
        <div class="ctax-record">
          <!-- Owner name -->
          <span class="resident"><xsl:value-of select="property/residents/resident/name" /></span>
          <!-- Account details -->
          <div class="claim-details">
            <!-- Property details -->
            <xsl:apply-templates select="property" />
            <div class="account-id">
              <span class="label">Account reference: </span>
              <xsl:value-of select="accountId" />
            </div>
            <div class="account-balance">
              <span class="label">Balance: </span>
              <xsl:call-template name="money"><xsl:with-param name="amount" select="accountBalance" /></xsl:call-template>
            </div>
            <div class="account-payment-method">
              <span class="label">Payment method: </span>
              <xsl:value-of select="paymentMethod/description" />
            </div>
          </div>
        </div>
        <div class='clear'></div>
        <div>
          <!-- Bill history -->
          <xsl:apply-templates select="bills">
            <xsl:with-param name="CTax_Index" select="$CTax_Index" />
          </xsl:apply-templates>
        </div>
        <div class="column1">
          <!-- Correspondence -->
          <xsl:for-each select="correspondence">
            <xsl:call-template name="correspondence-summary">
              <xsl:with-param name="index" select="$CTax_Index"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
        <div class="column2">
          <!-- Discounts -->
          <xsl:apply-templates select="instalments" />
          <xsl:apply-templates select="discounts" />
        </div>

        <!-- Recovery -->
        <xsl:if test="count(recovery) > 0">
          <xsl:apply-templates select="recovery" />
        </xsl:if>
      </div>
      <hr class="clear"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="property">
    <xsl:apply-templates select="address" />
    <div class="council-tax-band"><span class='label'>Council Tax Band: </span><xsl:value-of select="band" /></div>
    <div class="occupancy-started">
      <span class="label">Liability date: </span>
      <xsl:value-of select="php:function('achieveservice_ws_format_date', string(occupancyStartDate))" />
    </div>
  </xsl:template>
  
  <xsl:template name="make-a-payment-link">
    <xsl:for-each select="ancestor::CTax">
      <xsl:variable name="form-index" select="count(preceding-sibling::CTax) + 1"/>
      <xsl:apply-templates select="links/link[@id='make_payment_form']">
        <xsl:with-param name="extra-params" select="concat('Payment_amount=', balance, '&amp;Council_Tax_account_number=', accountId, '&amp;', $form-index-param, '=', $form-index)"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="request-an-arrangement-link">
    <xsl:apply-templates select="/feed/ServicesResponseEnvelope/CTax/links/link[@id='request_new_arrangement']"/>
  </xsl:template>
  
  <xsl:template name="debt-contact-link">
    <a href="mailto:{$debt-contact-email}?subject=Re: Council Tax Account {ancestor::CTax/accountId} {recoveryInfo/status}"><xsl:value-of select="$debt-contact-email"/></a>
  </xsl:template>

  <xsl:template name="court-contact-link">
    <a href="mailto:{$court-contact-email}?subject=Re: Council Tax Account {ancestor::CTax/accountId} {recoveryInfo/status}"><xsl:value-of select="$court-contact-email"/></a>
  </xsl:template>

  <!-- Bill history -->
  <xsl:template match="bills">
	<xsl:param name="CTax_Index" />
    <div class="bills">
      <h3>Bill History</h3>
      <table>
        <thead>
          <tr>
            <th></th>
            <th class="bill-period-heading">Bill Period</th>
            <th>Balance</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="bill">
            <xsl:sort data-type="number" select="number" order="descending" />
            <tr>
              <xsl:attribute name="class">
                <xsl:if test="position() mod 2">odd</xsl:if>
              </xsl:attribute>
              <td><xsl:value-of select="number" /></td>
              <td>
                <a title="View details of this bill">
                  <xsl:attribute name="href">
                    <!--<xsl:text>http://fs-downloads.s3.amazonaws.com/GM/services/CTax.pdf</xsl:text>-->
                    <xsl:value-of select="concat(php:function('base_path'), $bill_detail_path, '?index=', string($CTax_Index), '&amp;billno=', string(number))" />
                  </xsl:attribute>
                  <xsl:value-of select="php:function('achieveservice_ws_format_date', string(fromDate))" />
                  to
                  <xsl:value-of select="php:function('achieveservice_ws_format_date', string(toDate))" />
                </a>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="number(balance) = 0">
                    <xsl:text>Paid</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <strong><xsl:call-template name="money"><xsl:with-param name="amount" select="balance" /></xsl:call-template></strong>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td>
                <!-- Recovery -->
                <div style='display:none;'>
                  <xsl:copy-of select="."/>
                </div>
                <xsl:choose>
                  <xsl:when test="(count(recoveryInfo)>0) and (number(balance) != 0)">
                    <span class="detail-item">
                      <xsl:if test="string-length(recoveryInfo/caseNo) > 0">
                        <xsl:value-of select="concat('[Case ', recoveryInfo/caseNo, '] ')"/>
                      </xsl:if>
                      <span class="details-item">
                        <xsl:choose>
                          <xsl:when test="recoveryInfo/status = 'Final Notice'">
                          
                            <xsl:value-of select="'This bill has had a final notice issued. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                <ul>
                                  <li>
                                    This bill amount is due in full immediately.
                                    <xsl:call-template name="make-a-payment-link"/>
                                  </li>
                                  <li>
                                    You may <xsl:call-template name="request-an-arrangement-link"/> if you sign up for Direct Debit.
                                  </li>
                                  <li>
                                    Alternatively, contact us via email at
                                    <xsl:call-template name="debt-contact-link"/>
                                    or by calling <xsl:value-of select="$debt-contact-phone"/>.
                                  </li>
                                </ul>
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/type = 'Reminder'">
                          
                            <xsl:value-of select="'This bill has had a reminder issued. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                <ul>
                                  <li>
                                    <xsl:call-template name="make-a-payment-link" />
                                  </li>
                                  <li>
                                    <xsl:call-template name="request-an-arrangement-link" />
                                  </li>
                                </ul>
                                <strong>Note:</strong> All arrangement requests are subject to approval by the Council.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = '14 Day Letter'">
                          
                            <xsl:value-of select="'This bill has had a 14 Day Letter issued. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                Please contact the Corporate Debt Team at <xsl:call-template name="debt-contact-link"/> or by phoning <xsl:value-of select="$debt-contact-phone" />.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Arrangement'">
                          
                            <xsl:value-of select="'Status: Arrangement. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                It is important to keep to your arrangement to avoid further recovery action being taken against you.
                                <br/>
                                If you need to discuss this arrangement, please contact the Corporate Debt Team at <xsl:call-template name="debt-contact-link"/>
                                or by phoning <xsl:value-of select="$debt-contact-phone" />.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Door Knockers'">
                          
                            <xsl:value-of select="'Status: Door Knockers. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                Please contact the Corporate Debt Team at <xsl:call-template name="debt-contact-link"/> or by phoning <xsl:value-of select="$debt-contact-phone" />.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Attachment of Earnings'">
                          
                            <xsl:value-of select="'These arrears are being collected directly from your employer. Please contact your employer for the deduction rates.'"/>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Attachment of Benefits'">
                          
                            <xsl:value-of select="'These arrears are being collected directly from your benefits. '"/>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Charging Order'">
                          
                            <xsl:value-of select="'Status: Charging Order. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                If you need to discuss this, please contact the Corporate Court Officer at <xsl:call-template name="court-contact-link"/> or by phoning <xsl:value-of select="$court-contact-phone"/>.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Insolvency'">
                          
                            <xsl:value-of select="'Status: Insolvency. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                If you need to discuss this, please contact the Corporate Court Officer at <xsl:call-template name="court-contact-link"/> or by phoning <xsl:value-of select="$court-contact-phone"/>.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Bailiff'">
                          
                            <xsl:variable name="bailiffAction" select="recoveryInfo/details/outcome/action[type='Bailiff'][1]"/>
                          
                            <xsl:value-of select="concat('This bill is being managed by the bailiffs (', $bailiffAction/collectorDetails/name, '). ')"/>
                            
                            <xsl:variable name="modalId_bailiffInfo" select="concat('bailiffInfo_', generate-id($bailiffAction))"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_bailiffInfo"/>
                              <xsl:with-param name="body">
                                <p>
                                  This bill is being managed by the bailiff firm, <span class="collector-name"><xsl:value-of select="$bailiffAction/collectorDetails/name"/></span>.
                                </p>
                                <p>
                                  The order was issued on <xsl:call-template name="date"><xsl:with-param name="date" select="$bailiffAction/issueDate"/></xsl:call-template> to
                                  recover <xsl:call-template name="money"><xsl:with-param name="amount" select="$bailiffAction/issueAmount"/></xsl:call-template>.
                                </p>
                                <p>
                                  If you need to contact the firm, we have the following contact details on record:
                                </p>
                                <ul>
                                  <xsl:if test="string($bailiffAction/collectorDetails/telephoneNo) != ''">
                                    <li>
                                      Telephone:
                                      <xsl:value-of select="$bailiffAction/collectorDetails/telephoneNo"/>
                                    </li>
                                  </xsl:if>
                                  <li>
                                    Address:
                                    <xsl:apply-templates select="$bailiffAction/collectorDetails/address"/>
                                  </li>
                                </ul>
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_bailiffInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Summons'">
                          
                            <xsl:value-of select="'This bill has had a summons issued against it. '"/>
                            
                            <xsl:variable name="modalId_reminderInfo" select="concat('reminderInfo_', generate-id())"/>
                            <xsl:call-template name="create-modal">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="body">
                                If you need to discuss this, please contact the Corporate Court Officer at <xsl:call-template name="court-contact-link"/> or by phoning <xsl:value-of select="$court-contact-phone"/>.
                              </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="modal-link">
                              <xsl:with-param name="id" select="$modalId_reminderInfo"/>
                              <xsl:with-param name="text">Click here for your options.</xsl:with-param>
                            </xsl:call-template>
                            
                          </xsl:when>
                          <xsl:when test="recoveryInfo/status = 'Due'">
                            <xsl:value-of select="'This amount is due to be paid immediately.'"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="concat('Status: ', recoveryInfo/status, '.')"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </span>
                    </span>
                    
                    <xsl:value-of select="' '"/>
                    
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="empty-box"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- Related links -->
  <xsl:template name="links" >
    <xsl:variable name="form-index" select="count(preceding-sibling::CTax) + 1"/>
    <xsl:for-each select="links">
      <div class="links">
        <!-- Output non-internal form links -->
        <xsl:for-each select="link[@type='external' and (not(@scope) or @scope!='global')]">
          <xsl:apply-templates select="." />
        </xsl:for-each>
        <xsl:for-each select="link[(not(@rel) or @rel!='internal') and @type='form' and (not(@scope) or @scope!='global')]">
          <xsl:apply-templates select=".">
            <xsl:with-param name="extra-params" select="concat($form-index-param, '=', $form-index)"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </div>
    </xsl:for-each>
  </xsl:template>

  <!-- Discounts -->
  <xsl:template match="discounts">
    <div class="discounts">
      <h3>Discounts</h3>
      <table>
        <thead>
          <tr>
            <th>From</th>
            <th>To</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="discount">
            <tr>
              <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(fromDate))" /></td>
              <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(toDate))" /></td>
              <td><xsl:value-of select="type" /></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

	  <!-- Instalments -->
	  <xsl:template match="instalments">
      <xsl:if test="count(billInstalments/instalment) > 0">
		    <div class="instalments">
		      <h3>Instalment Plan</h3>
		      <table>
		        <thead>
		          <tr>
		            <th>Due Date</th>
		            <th>Instalment Amount</th>
		            <th>Unpaid Amount</th>
		          </tr>
		        </thead>
		        <tbody>
		          <xsl:for-each select="billInstalments">
		            <xsl:sort data-type="text" select="instalment/dueDate" order="ascending" />
		
			          <xsl:for-each select="instalment">
			            <xsl:sort data-type="text" select="dueDate" order="ascending" />
		           		<tr>
			              <td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(dueDate))" /></td>
			              <td><xsl:call-template name="money"><xsl:with-param name="amount" select="instalmentAmount"/></xsl:call-template></td>
			              <td><xsl:call-template name="money"><xsl:with-param name="amount" select="instalmentAmountUnpaid"/></xsl:call-template></td>
			            </tr>
			          </xsl:for-each>
		          </xsl:for-each>
		        </tbody>
		      </table>
		    </div>
			</xsl:if>
	  </xsl:template>

  <!-- Correspondence list -->
  <xsl:template match="correspondence">
    <xsl:param name="CTax_Index"/>
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
          <xsl:for-each select="outgoing/item[position() &lt;= 5]">
            <xsl:sort data-type="text" select="sentDate" order="descending" />
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
          </xsl:for-each>
          <xsl:if test="count(outgoing/item) &gt; 5">
            <tr class="link-row">
              <td colspan="3">
                <a title="Full correspondence history">
                  <xsl:attribute name="href">
                    <xsl:value-of select="php:function('base_path')" /><xsl:value-of select="concat($correspondence_history_path, '?index=', string($CTax_Index))" />
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

  <!-- Debt recovery cases -->
  <xsl:template match="recovery">
    <xsl:if test="count(case) > 0">
      <div class="recovery">
        <h3>Recovery</h3>
        <xsl:apply-templates select="case" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="case">
    <div class="recovery-case">
      <h4>Case <xsl:value-of select="caseNo" /></h4>
      <span>Status: <xsl:value-of select="status" /></span>
      <xsl:if test="status != 'Bailiff'">
        <span class="form-link">
          <xsl:apply-templates select="//link[@id='request_new_arrangement']" />
        </span>
      </xsl:if>
      <xsl:for-each select="debt">
        <div class="debt">
          <h5>Debt</h5>
          <table class="horizontal">
            <tbody>
              <tr><th>Balance</th><td><xsl:call-template name="money"><xsl:with-param name="amount" select="currentBalance"/></xsl:call-template></td></tr>
              <tr><th>Order Costs</th><td><xsl:call-template name="money"><xsl:with-param name="amount" select="liableOrderCosts"/></xsl:call-template></td></tr>
              <tr><th>Order Debt</th><td><xsl:call-template name="money"><xsl:with-param name="amount" select="liableOrderDebt"/></xsl:call-template></td></tr>
              <tr><th>Summons Costs</th><td><xsl:call-template name="money"><xsl:with-param name="amount" select="summonsCosts"/></xsl:call-template></td></tr>
              <tr><th>Summons Debt</th><td><xsl:call-template name="money"><xsl:with-param name="amount" select="summonsedDebt"/></xsl:call-template></td></tr>
            </tbody>
          </table>
        </div>
      </xsl:for-each>
      <xsl:for-each select="summons">
        <div class="summons">
          <h5>Summons</h5>
          <table class="horizontal">
            <tbody>
              <tr><th>Summons date</th><td><xsl:value-of select="summonsDate" /></td></tr>
              <tr><th>Court Code</th><td><xsl:value-of select="court/courtCode" /></td></tr>
              <tr><th>Court description</th><td><xsl:value-of select="court/courtDescription" /></td></tr>
              <tr><th>Hearing date</th><td><xsl:value-of select="hearing/hearingDateTime" /></td></tr>
              <xsl:if test="adjournDateTime">
                <tr><th>Hearing adjouned date</th><td><xsl:value-of select="hearing/adjournDateTime" /></td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>
      </xsl:for-each>
      <xsl:for-each select="outcome">
        <div class="outcomes">
          <h5>Outcome</h5>
          <table class="horizontal">
            <tbody>
              <tr><th>Type</th><td><xsl:value-of select="actionType" /></td></tr>
              <tr><th>Description</th><td><xsl:value-of select="actionCodeDescription" /></td></tr>
              <xsl:if test="collector">
                <tr><th>Collector</th><td><xsl:value-of select="collector" /></td></tr>
              </xsl:if>
              <tr><th>Issue date</th><td><xsl:value-of select="php:function('achieveservice_ws_format_date', string(issueDate))" /></td></tr>
              <tr><th>Issue amount</th><td>£<xsl:value-of select="issueAmount" /></td></tr>
              <xsl:if test="liablePerson">
                <tr><th>Liable person</th><td><xsl:value-of select="liablePerson" /></td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
</xsl:stylesheet>
