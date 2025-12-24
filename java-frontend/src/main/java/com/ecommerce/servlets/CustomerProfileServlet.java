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

@WebServlet("/profile")
public class CustomerProfileServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE = "http://localhost:5004/api/customers";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");

        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("main");
            return;
        }

        HttpClient client = HttpClient.newHttpClient();

        try {
            HttpRequest custReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE + "/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> custRes = client.send(custReq, HttpResponse.BodyHandlers.ofString());

            if (custRes.statusCode() == 200) {
                request.setAttribute("customerJson", custRes.body());
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch customer profile");
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
