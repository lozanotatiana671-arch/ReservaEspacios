package com.reservas;

public class Banner {
    private int id;
    private String titulo;
    private String imagen;
    private boolean activo;

    // Getters y Setters
    public int getId() { 
        return id; 
    }

    public void setId(int id) { 
        this.id = id; 
    }

    public String getTitulo() { 
        return titulo; 
    }

    public void setTitulo(String titulo) { 
        this.titulo = titulo; 
    }

    public String getImagen() { 
        return imagen; 
    }

    public void setImagen(String imagen) { 
        this.imagen = imagen; 
    }

    public boolean isActivo() { 
        return activo; 
    }

    public void setActivo(boolean activo) { 
        this.activo = activo; 
    }
}
