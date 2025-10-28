package com.reservas;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    private static final String URL = "jdbc:oracle:thin:@localhost:1521:XE"; 
    private static final String USER = "system";   // tu usuario Oracle
    private static final String PASSWORD = "admin"; // tu contraseña

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Error: No se encontró el Driver de Oracle JDBC.", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
