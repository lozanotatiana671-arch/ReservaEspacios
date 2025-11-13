package com.reservas;

public class Consulta {

    private int id;
    private int usuarioId;
    private String nombre;
    private String correo;
    private String mensaje;
    private String fecha;

    // Getters y Setters
    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public int getUsuarioId() { 
        return usuarioId; 
    }
    public void setUsuarioId(int usuarioId) { 
        this.usuarioId = usuarioId; 
    }

    public String getNombre() { 
        return nombre; 
    }
    public void setNombre(String nombre) { 
        this.nombre = nombre; 
    }

    public String getCorreo() { 
        return correo; 
    }
    public void setCorreo(String correo) { 
        this.correo = correo; 
    }

    public String getMensaje() { 
        return mensaje; 
    }
    public void setMensaje(String mensaje) { 
        this.mensaje = mensaje; 
    }

    public String getFecha() { 
        return fecha; 
    }
    public void setFecha(String fecha) { 
        this.fecha = fecha; 
    }
}
