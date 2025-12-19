<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.json.JSONObject" %>
        <%@ page import="org.json.JSONArray" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>All Customers - E-Commerce System</title>
                <link rel="stylesheet" href="css/main.css">
            </head>

            <body>
                <div class="container">
                    <a href="index.jsp" class="back-link">← Back to Home</a>

                    <h1>Customer List</h1>

                    <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) {
                        String customersJson=(String) request.getAttribute("customersJson"); JSONObject jsonResponse=new
                        JSONObject(customersJson); JSONArray customers=jsonResponse.getJSONArray("customers"); %>

                        <table>
                            <thead>
                                <tr>
                                    <th>Customer ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Loyalty Points</th>
                                    <th>Created At</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i=0; i < customers.length(); i++) { JSONObject
                                    customer=customers.getJSONObject(i); int customerId=customer.getInt("customer_id");
                                    %>
                                    <tr>
                                        <td>
                                            <%= customerId %>
                                        </td>
                                        <td>
                                            <%= customer.getString("name") %>
                                        </td>
                                        <td>
                                            <%= customer.getString("email") %>
                                        </td>
                                        <td>
                                            <%= customer.optString("phone", "N/A" ) %>
                                        </td>
                                        <td>
                                            <%= customer.getInt("loyalty_points") %>
                                        </td>
                                        <td>
                                            <%= customer.getString("created_at") %>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="updateLoyalty?customer_id=<%= customerId %>"
                                                    class="action-btn btn-update">Update Points</a>
                                                <a href="customerOrders?customer_id=<%= customerId %>"
                                                    class="action-btn btn-orders">View Orders</a>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                            </tbody>
                        </table>

                        <% } else { String error=(String) request.getAttribute("error"); %>

                            <div class="alert alert-error">
                                <strong>Error:</strong>
                                <%= error !=null ? error : "Unknown error occurred" %>
                            </div>

                            <% } %>

                                <div class="nav-buttons" style="margin-top: 30px;">
                                    <a href="products" class="btn btn-primary">View Products</a>
                                    <a href="createOrder" class="btn btn-primary">Create Order</a>
                                </div>
                </div>
            </body>

            </html>