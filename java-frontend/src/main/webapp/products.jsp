<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.json.JSONObject" %>
        <%@ page import="org.json.JSONArray" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>All Products - E-Commerce System</title>
                <link rel="stylesheet" href="css/main.css">
            </head>

            <body>
                <div class="container">
                    <a href="index.jsp" class="back-link">← Back to Home</a>

                    <h1>Product Inventory</h1>

                    <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) {
                        String productsJson=(String) request.getAttribute("productsJson"); JSONObject jsonResponse=new
                        JSONObject(productsJson); JSONArray products=jsonResponse.getJSONArray("products"); %>

                        <table>
                            <thead>
                                <tr>
                                    <th>Product ID</th>
                                    <th>Product Name</th>
                                    <th>Price ($)</th>
                                    <th>Quantity Available</th>
                                    <th>Last Updated</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i=0; i < products.length(); i++) { JSONObject
                                    product=products.getJSONObject(i);%>
                                    <tr>
                                        <td>
                                            <%= product.getInt("product_id") %>
                                        </td>
                                        <td>
                                            <%= product.getString("product_name") %>
                                        </td>
                                        <td>
                                            <%= String.format("%.2f", product.getDouble("unit_price")) %>
                                        </td>
                                        <td>
                                            <%= product.getInt("quantity_available") %>
                                        </td>
                                        <td>
                                            <%= product.getString("last_updated") %>
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
                                    <a href="customers" class="btn btn-primary">View Customers</a>
                                    <a href="createOrder" class="btn btn-primary">Create Order</a>
                                </div>
                </div>
            </body>

            </html>