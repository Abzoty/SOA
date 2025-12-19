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

@WebServlet("/customerOrders")
public class CustomerOrdersServlet extends HttpServlet {

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
            HttpRequest customerReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> customerRes = client.send(customerReq,
                    HttpResponse.BodyHandlers.ofString());

            if (customerRes.statusCode() == 200) {
                request.setAttribute("customerJson", customerRes.body());
            } else {
                request.setAttribute("error", "Failed to fetch customer details");
                request.getRequestDispatcher("customer-orders.jsp").forward(request, response);
                return;
            }

            // Fetch customer orders
            HttpRequest ordersReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId + "/orders"))
                    .GET()
                    .build();

            HttpResponse<String> ordersRes = client.send(ordersReq,
                    HttpResponse.BodyHandlers.ofString());

            if (ordersRes.statusCode() == 200) {
                request.setAttribute("ordersJson", ordersRes.body());
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch orders. Status: " + ordersRes.statusCode());
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", "Error connecting to Customer Service: " + e.getMessage());
        }

        request.getRequestDispatcher("customer-orders.jsp").forward(request, response);
    }
}