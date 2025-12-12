package com.ecommerce.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import org.json.JSONObject;

@WebServlet("/health")
public class HealthCheckServlet extends HttpServlet {

    private static final String[] SERVICES = {
            "http://localhost:5001/health",
            "http://localhost:5002/health",
            "http://localhost:5003/health",
            "http://localhost:5004/health",
            "http://localhost:5005/health"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html><head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Service Health Check</title>");
        out.println("<link rel='stylesheet' href='css/health.css'>");
        out.println("</head><body>");

        out.println("<a href='index.jsp' class='back-link'>← Back to Home</a>");
        out.println("<h1>Microservices Health Check</h1>");

        HttpClient client = HttpClient.newHttpClient();

        for (String serviceUrl : SERVICES) {
            try {
                HttpRequest req = HttpRequest.newBuilder()
                        .uri(URI.create(serviceUrl))
                        .GET()
                        .build();

                HttpResponse<String> res = client.send(req,
                        HttpResponse.BodyHandlers.ofString());

                JSONObject json = new JSONObject(res.body());
                String serviceName = json.getString("service");

                out.println("<div class='service healthy'>");
                out.println("<strong>" + serviceName + "</strong>: ✓ Healthy");
                out.println("</div>");

            } catch (Exception e) {
                out.println("<div class='service unhealthy'>");
                out.println("<strong>" + serviceUrl + "</strong>: ✗ Unreachable - " +
                        e.getMessage());
                out.println("</div>");
            }
        }

        out.println("</body></html>");
    }
}