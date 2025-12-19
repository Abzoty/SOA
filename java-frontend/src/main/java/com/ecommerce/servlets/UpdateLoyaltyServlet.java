package com.ecommerce.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import org.json.JSONObject;

@WebServlet("/updateLoyalty")
public class UpdateLoyaltyServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");

        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("customers");
            return;
        }

        HttpClient client = HttpClient.newHttpClient();

        try {
            // Fetch customer details
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> res = client.send(req,
                    HttpResponse.BodyHandlers.ofString());

            if (res.statusCode() == 200) {
                request.setAttribute("customerJson", res.body());
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch customer. Status: " + res.statusCode());
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", "Error connecting to Customer Service: " + e.getMessage());
        }

        request.getRequestDispatcher("update-loyalty.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        String pointsChange = request.getParameter("points_change");

        if (customerId == null || pointsChange == null) {
            response.sendRedirect("updateLoyalty?customer_id=" + customerId + "&error=missing_fields");
            return;
        }

        try {
            // Build JSON payload
            JSONObject payload = new JSONObject();
            payload.put("points_change", Integer.parseInt(pointsChange));

            // Call Customer Service
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId + "/loyalty"))
                    .header("Content-Type", "application/json")
                    .PUT(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();

            HttpResponse<String> res = client.send(req,
                    HttpResponse.BodyHandlers.ofString());

            if (res.statusCode() == 200) {
                // Success - redirect back to customers page
                response.sendRedirect("customers");
            } else {
                // Error - redirect back to form with error
                response.sendRedirect("updateLoyalty?customer_id=" + customerId + "&error=update_failed");
            }

        } catch (Exception e) {
            // Error - redirect back to form with error
            response.sendRedirect("updateLoyalty?customer_id=" + customerId + "&error=exception");
        }
    }
}