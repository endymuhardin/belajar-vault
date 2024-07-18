package com.muhardin.endy.belajar.vault.entity;

import java.math.BigDecimal;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;

@Entity @Data
public class Produk {
    @Id @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String kode;
    private String nama;
    private BigDecimal harga;
}
