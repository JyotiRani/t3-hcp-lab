# Agentic Integration with IBM webMethods Hybrid Integration

AI becomes truly effective only when integration aggregates, transforms, and contextualizes enterprise data. This lab focuses on integrating AI agents into enterprise systems using IBM webMethods Hybrid Integration. Participants will explore Integration workflows and API Gateway for seamless data exchange, transformation, system interoperability as well as security and governance.


# IBM webMethods Hybrid Integration

IBM webMethods Hybrid Integration enables enterprises to connect APIs, applications, events, B2B, and files across hybrid and multi-cloud environments through a unified integration platform. By aggregating, transforming, and governing enterprise data into canonical, AI-ready formats, webMethods Hybrid Integration powers AI to deliver accurate insights, automation, and intelligent business decisions.

# Architecture

Integration powers AI by transforming fragmented enterprise data into contextual intelligence AI can act on. Integration responsibilities:

- Aggregating data from multiple systems
- Transforming schemas
- Normalizing dates and formats
- Masking sensitive data
- Creating a canonical AI-ready payload
- Security and governance

```
                    ┌─────────────────────────────┐
                    │        Customer Channel     │
                    │  Chatbot / Portal / API     │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                        ┌────────────────────┐
                        │  Integration Layer │
                        │ (API / Workflow)   │
                        └─────────┬──────────┘
                                  │
                 ┌────────────────┼────────────────┐
                 │                │                │
                 ▼                ▼                ▼
        ┌─────────────┐  ┌─────────────┐  ┌──────────────┐
        │    CRM      │  │     ERP     │  │  Logistics   │
        │ Customer DB │  │ Order Mgmt  │  │ Shipping API │
        └──────┬──────┘  └──────┬──────┘  └──────┬───────┘
               │                │                │
               └──────────────┬─┴───────────────┘
                              ▼
                ┌───────────────────────────┐
                │   Data Transformation     │
                │                           │
                │ • Schema mapping          │
                │ • Date conversion         │
                │ • Data enrichment         │                    │
                │ • Canonical model         │
                └──────────────┬────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      AI Engine       │
                    │      (Optional)      │
                    │                      │
                    │ Issue analysis       │
                    │ Root cause insight   │
                    │ Resolution suggestion│
                    └───────────┬──────────┘
```

### Components

1. Customer reports a delayed order
2. Integration Layer (API + Workflow)
- Orchestrates system calls
- Ensures security & governance
3. Enterprise Systems CRM (Customer profile) ERP (Order information) Logistics (Shipment status)
4. Data Transformation Layer
- Schema mapping across systems
- Date format conversion
- Data enrichment
- Canonical AI-ready model
5. AI Engine (Optional)
- Understands issue context
- Recommends resolution
- Update CRM support ticket
- Notify customer of delay
- Trigger follow-up workflow

## Prerequisites

### Required Software

- **Web Browser** (Chrome, Firefox, or Safari)

### Required Accounts

- Access to [IBM webMethods Hybrid Integration tenant](https://dev3553628.a-vir-r1.int.ipaas.automation.ibm.com/)
- API Key (provided by instructor)


# 1. Integration Workflow Orchestration

<details><summary>CLICK ME</summary>

### 1. Download the integration workflow

Download the workflow [here](files/Integration-workflow-export.zip).

### 2. Import the workflow in webMethods

1. Login to https://dev3553628.a-vir-r1.int.ipaas.automation.ibm.com/

2. Access **webMethods Integration**

<img src="images/image1.png" >

3. Create new Project 

<img src="images/image2.png" >

4. Enter unique project name and Click Create.

<img src="images/image3.png" >

5. On the newly create project home page, Click Import.

<img src="images/image4.png" >

6. Select the archive downloaded in Step 1 above.

7. Review the workflow name, description

<img src="images/image5.png" >

8. Click on the + sign next to **Connect to HyperText Transfer Protocol (HTTP)**

<img src="images/image6.png" >

9. Enter http://dev3553628.a-vir-d1.apigw.ipaas.automation.ibm.com/gateway/T3Demo/1.0/customer/ in the URL field and Click Add.

<img src="images/image7.png" >

10. Select newly created account for the next two HTTP Connectors and Click Import.

<img src="images/image8.png" >

### 3. Review the Workflow

1. Click on the pencil icon (Edit) on the TrackShipment Workflow.

<img src="images/image12.png" >

2. Review each node in the imported Workflow

<img src="images/image13.png" >

3. Double click on the first node (Webhook) and review the Webhook configuration like Webhook url and payload and then Click Cancel. This Workflow is triggered with POST call to Webhook URL with specified payload.

<img src="images/image14.png" >

4. Double click the getCustomer node and review the configuration. This node calls the getCustomer Flow service to fetch details of the specified CustomerId from CRM system.

<img src="images/image15.png" >

<img src="images/image16.png" >

5. Double click the getOrder node and review the configuration. This node calls the getOrder Flow service to fetch details of the specified orderId from ERP system.

<img src="images/image17.png" >

<img src="images/image18.png" >

6. Double click the getShipment node and review the configuration. This node calls the getShipment Flow service to fetch Logisitics details of the specified orderId from Logisitics system.

<img src="images/image19.png" >

<img src="images/image20.png" >

7. Double click the Response node, this node represents the customized JSON response to be sent after consolidating the response from CRM, ERP and Logisitics system.

<img src="images/image21.png" >

8. Click Next and review the field mappings

<img src="images/image22.png" >

9. Expand the Transform section on the left side and click on the pencil icon next to custname.

<img src="images/image23.png" >

10. Review the Concat transformation which combines the customer firstname and lastname as custname.

<img src="images/image24.png" >

11. Similarly, review the ToLower transformation which converts the orderstatus to Lower case.

<img src="images/image25.png" >

12. Review the ToLower transformation which converts the shippingStatus to Lower case.

<img src="images/image26.png" >

13. Review the Convert date to ISO format transformation for orderdate format conversion to ISO format.

<img src="images/image27.png" >

14. Review the other field mappings to prepare customized JSON response and Click Next.

<img src="images/image28.png" >

15. Click Cancel to undo any changes to the workflow.

<img src="images/image29.png" >

16. Run the Workflow by clicking the play icon at the top right corner.

<img src="images/image30.png" >

17. Notice the workflow execution as the request pass through each node in the workflow.

<img src="images/image31.png" >

18. Click Execution History to review the execution results

<img src="images/image32.png" >

19. Click Return Data on Sync Webhook

<img src="images/image33.png" >

20. Click the Output tap and review the returned response JSON Output.

<img src="images/image34.png" >


</details>

# 2. Create API in webMethods Integration

<details><summary>CLICK ME</summary>

### 1. Create API for Integration Workflow

1. Click APIs 

<img src="images/gw1.png" >

2. Click Create API

<img src="images/gw2.png" >

3. Enter the API name as **trackShipment**, version **1.0** and Click Save

<img src="images/gw3.png" >

4. Click Add resource

<img src="images/gw4.png" >

5. Enter Path as /trackshipment and Select HTTP POST method

<img src="images/gw5.png" >

6. Under Select Services dropdown, select TrackShipment.

<img src="images/gw6.png" >

7. Click Save

<img src="images/gw7.png" >

8. Under API details, Click on the download icon for the Public URL, under YAML section as shown below to download the API swagger file.

<img src="images/gw8.png" >

Now, we have created an API which can combine response from multiple systems, perform transformation and return a unified response which can be called by an agent or other application components.

</details>

# 3. Secure API in API Gateway and Publish to Developer Portal

<details><summary>CLICK ME</summary>

### 1. Import API in API Gateway

1. Go to webMethods API Gateway 

<img src="images/gw9.png" >

2. Click APIs

<img src="images/gw10.png" >

3. Browse for the Swagger file trackshipment.yaml downloaded in Step 8 of previous section.

<img src="images/gw11.png" >

4. Enter a unique name for the API, and select Type as Swagger and Click Create.

<img src="images/gw12.png" >

5. Review the Basic Information, Technical Information 

<img src="images/gw13.png" >

6. Review Resources and Methods section for the POST endpoint

<img src="images/gw14.png" >

### 2. Secure API

1. Click Policies

<img src="images/gw15.png" >

2. Click Edit to apply policies to the API

<img src="images/gw16.png" >

3. Expand Trasport section and Click + sign next to Enable HTTP/HTTPS

<img src="images/gw17.png" >

4. Select HTTPS, this will enable HTTPS endpoint for the API

<img src="images/gw18.png" >

5. Expand Identity & Access and CLICK + sign next to Identity & Authorize

<img src="images/gw19.png" >

6. Edit the Authorization settings as shown below. This will allow Anonnymous user access to the API. Basic authentication for the authenticated consumer applications when they subscribe to the API.

<img src="images/gw20.png" >

7. Expand the Routing section and Click + sign next to Custom HTTP Header

<img src="images/gw21.png" >

8. Enter X-INSTANCE-API-KEY in the HTTP Header Key and Set the value as shared by the instructor and Click Add.

<img src="images/gw22.png" >

<img src="images/gw23.png" >

9. Expand Traffic Monitoring and Click + sign next to Traffic Optimization

<img src="images/gw24.png" >

10. Set the values as shown below to define rate-limit for the API calls. This will ensure if there are more than 3 API Calls across consumers in 2 minutes duration, further Calls to the API will be blocked with a message **Limit Exceeded!!**

<img src="images/gw25.png" >

<img src="images/gw26.png" >

11. Click + sign next to Service Result Cache to define caching policies for the API Response

<img src="images/gw27.png" >

12. Set the Time to Live value as 1 and Payload Size 10000

<img src="images/gw28.png" >

13. Expand the Response Processing section and Click + sign next to Data Masking to define masking rules

<img src="images/gw29.png" >

14. Under JSON Path, Click Add masking criteria

<img src="images/gw30.png" >

15. Enter $..email in the Query Expression and enter 8 astrics (*)  in the mask value and Click Add

<img src="images/gw31.png" >

This will mask customer email in the returned API response for privacy purpose.

16. Save and Activate the API

<img src="images/gw32.png" >

<img src="images/gw33.png" >

17. Click Publish to publish the updated API

<img src="images/gw34.png" >

18. Select both the HTTP and HTTPS endpoint and Click Publish

<img src="images/gw35.png" >

Now, you have published the updated API to Developer Portal.

</details>

# 4. Verify and Test the API

<details><summary>CLICK ME</summary>

### 1. Developer Portal

1. Go to Developer Portal

<img src="images/gw36.png" >

2. Click on API Gallery and browse for your published API.

<img src="images/portal1.png" >

3. Verify both the HTTP and HTTPS endpoints are available for the API and Click Try API.

<img src="images/portal2.png" >

4. Select the POST endpoint.

5. Click Request Body and enter the following payload.

```
{
"ticketId": "TCKT-90213",
"customerId": "CUST001",
"orderId": "ORD004",
"issueType": "DELIVERY_DELAY",
"message": "My order hasn't arrived yet"
}

```

<img src="images/portal3.png" >

6. Click Send and review the response.

<img src="images/portal4.png" >

```
1. Customer name is Full name with firstname and lastname 
```
```
2. Customer email id is masked for security reasons
```
```
3. Order date is converted into ISO format
```
```
4. Shipping status is being normalized to lowercase
```

7. Next, ensure caching is working by Clicking the Send button again and notice the response time is reduced since the data is being fetched from cache.

8. Since the rate limit is configured as 3, after clicking the Send button more than 3 times across consumers in 2 mins, you should see the HTTP response code 429 Too Many Requests which prevents further calls to the API with message **Limit Exceeded!!**	 as configured in API policy.

<img src="images/portal5.png" >


</details>