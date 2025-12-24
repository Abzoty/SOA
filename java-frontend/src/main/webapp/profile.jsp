<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Customer Profile</title>
            <link rel="stylesheet" href="css/profile.css">
        </head>

        <body>
            <div class="container">
                <h1>Customer Profile</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { String
                    customerJson=(String) request.getAttribute("customerJson"); JSONObject customer=new
                    JSONObject(customerJson); %>

                    <div class="profile-card">
                        <h3>Profile Information</h3>
                        <div class="profile-row">
                            <strong>Customer ID:</strong>
                            <span>
                                <%= customer.getInt("customer_id") %>
                            </span>
                        </div>
                        <div class="profile-row">
                            <strong>Name:</strong>
                            <span>
                                <%= customer.getString("name") %>
                            </span>
                        </div>
                        <div class="profile-row">
                            <strong>Email:</strong>
                            <span>
                                <%= customer.getString("email") %>
                            </span>
                        </div>
                        <div class="profile-row">
                            <strong>Phone:</strong>
                            <span>
                                <%= customer.optString("phone", "N/A" ) %>
                            </span>
                        </div>
                        <div class="profile-row" style="background: #d4edda; font-weight: bold;">
                            <strong>Loyalty Points:</strong>
                            <span>
                                <%= customer.getInt("loyalty_points") %>
                            </span>
                        </div>
                    </div>

                    <% } else { %>

                        <div class="error">
                            <%= request.getAttribute("error") %>
                        </div>

                        <% } %>

                            <a href="main" class="btn">Back to Main</a>
            </div>
        </body>

        </html>