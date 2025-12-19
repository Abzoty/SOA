<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.json.JSONObject" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Update Loyalty Points - E-Commerce System</title>
            <link rel="stylesheet" href="css/main.css">
            <link rel="stylesheet" href="css/form.css">
        </head>

        <body>
            <div class="container">
                <a href="customers" class="back-link">← Back to Customers</a>

                <h1>Update Loyalty Points</h1>

                <% String errorParam=request.getParameter("error"); if (errorParam !=null) { String errorMessage="" ; if
                    (errorParam.equals("missing_fields")) { errorMessage="Missing required fields. Please try again." ;
                    } else if (errorParam.equals("update_failed")) {
                    errorMessage="Failed to update loyalty points. Please try again." ; } else if
                    (errorParam.equals("exception")) { errorMessage="An error occurred. Please try again." ; } else {
                    errorMessage="An unknown error occurred." ; } %>
                    <div class="alert alert-error">
                        <strong>Error:</strong>
                        <%= errorMessage %>
                    </div>
                    <% } Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) {
                        String customerJson=(String) request.getAttribute("customerJson"); JSONObject customer=new
                        JSONObject(customerJson); int customerId=customer.getInt("customer_id"); String
                        customerName=customer.getString("name"); String customerEmail=customer.getString("email"); int
                        loyaltyPoints=customer.getInt("loyalty_points"); %>

                        <div class="customer-info"
                            style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 30px;">
                            <h3>Customer Information</h3>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                                <div>
                                    <strong>Customer ID:</strong>
                                    <%= customerId %>
                                </div>
                                <div>
                                    <strong>Name:</strong>
                                    <%= customerName %>
                                </div>
                                <div>
                                    <strong>Email:</strong>
                                    <%= customerEmail %>
                                </div>
                                <div>
                                    <strong>Current Loyalty Points:</strong>
                                    <span style="color: #007bff; font-size: 1.2em; font-weight: bold;">
                                        <%= loyaltyPoints %>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <form action="updateLoyalty" method="post">
                            <input type="hidden" name="customer_id" value="<%= customerId %>">

                            <h2>Adjust Loyalty Points</h2>

                            <div class="form-group">
                                <label for="points_change">Points Change *</label>
                                <input type="number" id="points_change" name="points_change" required
                                    placeholder="Enter positive number to add, negative to subtract">
                                <small style="color: #666; display: block; margin-top: 5px;">
                                    Examples: Enter 50 to add 50 points, enter -25 to subtract 25 points
                                </small>
                            </div>

                            <div class="form-actions">
                                <button type="submit">Update Points</button>
                                <a href="customers" class="btn btn-secondary"
                                    style="text-decoration: none; display: inline-block;">Cancel</a>
                            </div>
                        </form>

                        <% } else { String error=(String) request.getAttribute("error"); %>

                            <div class="alert alert-error">
                                <strong>Error:</strong>
                                <%= error !=null ? error : "Failed to load customer information" %>
                            </div>

                            <div class="nav-buttons" style="margin-top: 20px;">
                                <a href="customers" class="btn btn-primary">Back to Customers</a>
                            </div>

                            <% } %>
            </div>
        </body>

        </html>