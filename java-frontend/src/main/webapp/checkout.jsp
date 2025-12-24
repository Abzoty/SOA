<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <%@ page import="java.net.URLEncoder" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Checkout</title>
                <link rel="stylesheet" href="css/checkout.css">
            </head>

            <body>
                <div class="container">
                    <h1>Order Checkout</h1>

                    <% String customerId=(String) request.getAttribute("customerId"); String pricingDataStr=(String)
                        request.getAttribute("pricingData"); JSONObject pricingData=new JSONObject(pricingDataStr);
                        JSONArray items=pricingData.getJSONArray("items"); %>

                        <div class="section">
                            <h3>Customer ID: <%= customerId %>
                            </h3>
                        </div>

                        <div class="section">
                            <h3>Order Items</h3>
                            <table>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Discount</th>
                                    <th>Total</th>
                                </tr>
                                <% for (int i=0; i < items.length(); i++) { JSONObject item=items.getJSONObject(i); %>
                                    <tr>
                                        <td>
                                            <%= item.getString("product_name") %>
                                        </td>
                                        <td>
                                            <%= item.getInt("quantity") %>
                                        </td>
                                        <td>
                                            <%= String.format("%.2f", item.getDouble("unit_price")) %> EGP
                                        </td>
                                        <td>
                                            <%= String.format("%.0f%%", item.getDouble("discount_percentage")) %>
                                        </td>
                                        <td>
                                            <%= String.format("%.2f", item.getDouble("item_total")) %> EGP
                                        </td>
                                    </tr>
                                    <% } %>
                            </table>
                        </div>

                        <div class="summary">
                            <div class="summary-row">
                                <span>Subtotal:</span>
                                <span>
                                    <%= String.format("%.2f", pricingData.getDouble("subtotal")) %> EGP
                                </span>
                            </div>
                            <div class="summary-row">
                                <span>Tax (<%= String.format("%.0f", pricingData.getDouble("tax_rate")) %>%):</span>
                                <span>
                                    <%= String.format("%.2f", pricingData.getDouble("tax_amount")) %> EGP
                                </span>
                            </div>
                            <div class="summary-row total">
                                <span>Total:</span>
                                <span>
                                    <%= String.format("%.2f", pricingData.getDouble("total")) %> EGP
                                </span>
                            </div>
                        </div>

                        <form action="createOrderFinal" method="post">
                            <input type="hidden" name="customer_id" value="<%= customerId %>">
                            <textarea name="pricing_data" style="display:none;"><%= pricingDataStr %></textarea>

                            <div class="buttons">
                                <a href="main" class="btn btn-secondary">Cancel</a>
                                <button type="submit" class="btn btn-primary">Confirm Order</button>
                            </div>
                        </form>
                </div>
            </body>

            </html>