create table produk (
    id bigserial,
    kode varchar(50) not null,
    nama varchar(100) not null,
    harga decimal(19,2) not null,
    primary key (id)
);