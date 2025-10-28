package com.reservas;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    private static final String URL = "jdbc:postgresql://dpg-d40b35p5pdvs73fquhng-a.oregon-postgres.render.com:5432/reservas_db_hjqs?sslmode=require";
    private static final String USER = "reservas_db_hjqs_user";
    private static final String PASSWORD = "phnQYDnEARNfVIqNMAd230jrP0rJJdEu";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Error: No se encontró el Driver de PostgreSQL JDBC.", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
