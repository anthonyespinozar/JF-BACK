PGDMP       %                }            gestion_flota    17.4    17.4 _    |           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            }           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            ~           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false                       1262    16475    gestion_flota    DATABASE     s   CREATE DATABASE gestion_flota WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es-ES';
    DROP DATABASE gestion_flota;
                     postgres    false            �            1255    16662    calcular_costo_total()    FUNCTION     �   CREATE FUNCTION public.calcular_costo_total() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.costo_total := (SELECT precio FROM materiales WHERE id = NEW.material_id) * NEW.cantidad;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.calcular_costo_total();
       public               postgres    false            �            1255    16720    verificar_mantenimiento()    FUNCTION     �  CREATE FUNCTION public.verificar_mantenimiento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO alertas_mantenimiento (unidad_id, parte_id, mensaje)
    SELECT 
        u.id, p.id, 
        CONCAT('La parte ', p.nombre, ' de la unidad ', u.placa, ' requiere mantenimiento.')
    FROM unidades u
    JOIN partes_unidades p ON u.id = p.unidad_id
    WHERE u.id = NEW.id 
    AND (u.kilometraje - p.ultimo_mantenimiento_km) >= p.kilometraje_mantenimiento;

    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.verificar_mantenimiento();
       public               postgres    false            �            1259    16699    alertas_mantenimiento    TABLE     �  CREATE TABLE public.alertas_mantenimiento (
    id integer NOT NULL,
    unidad_id integer,
    parte_id integer,
    mensaje text NOT NULL,
    estado character varying(20) DEFAULT 'ACTIVO'::character varying,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT alertas_mantenimiento_estado_check CHECK (((estado)::text = ANY ((ARRAY['ACTIVO'::character varying, 'RESUELTO'::character varying])::text[])))
);
 )   DROP TABLE public.alertas_mantenimiento;
       public         heap r       postgres    false            �            1259    16698    alertas_mantenimiento_id_seq    SEQUENCE     �   CREATE SEQUENCE public.alertas_mantenimiento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.alertas_mantenimiento_id_seq;
       public               postgres    false    232            �           0    0    alertas_mantenimiento_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.alertas_mantenimiento_id_seq OWNED BY public.alertas_mantenimiento.id;
          public               postgres    false    231            �            1259    16576    choferes    TABLE     �   CREATE TABLE public.choferes (
    id integer NOT NULL,
    usuario_id integer,
    licencia character varying(50) NOT NULL,
    telefono character varying(15),
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.choferes;
       public         heap r       postgres    false            �            1259    16575    choferes_id_seq    SEQUENCE     �   CREATE SEQUENCE public.choferes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.choferes_id_seq;
       public               postgres    false    220            �           0    0    choferes_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.choferes_id_seq OWNED BY public.choferes.id;
          public               postgres    false    219            �            1259    16644    detalles_mantenimiento    TABLE       CREATE TABLE public.detalles_mantenimiento (
    id integer NOT NULL,
    mantenimiento_id integer,
    material_id integer,
    cantidad integer,
    costo_total numeric(10,2) DEFAULT 0,
    CONSTRAINT detalles_mantenimiento_cantidad_check CHECK ((cantidad > 0))
);
 *   DROP TABLE public.detalles_mantenimiento;
       public         heap r       postgres    false            �            1259    16643    detalles_mantenimiento_id_seq    SEQUENCE     �   CREATE SEQUENCE public.detalles_mantenimiento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.detalles_mantenimiento_id_seq;
       public               postgres    false    228            �           0    0    detalles_mantenimiento_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.detalles_mantenimiento_id_seq OWNED BY public.detalles_mantenimiento.id;
          public               postgres    false    227            �            1259    16733    duenos    TABLE     �   CREATE TABLE public.duenos (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    dni character varying(15) NOT NULL,
    contacto character varying(50) NOT NULL
);
    DROP TABLE public.duenos;
       public         heap r       postgres    false            �            1259    16732    duenos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.duenos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.duenos_id_seq;
       public               postgres    false    236            �           0    0    duenos_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.duenos_id_seq OWNED BY public.duenos.id;
          public               postgres    false    235            �            1259    16724    dueños    TABLE     �   CREATE TABLE public."dueños" (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    dni character varying(15) NOT NULL,
    contacto character varying(10) NOT NULL
);
    DROP TABLE public."dueños";
       public         heap r       postgres    false            �            1259    16723    dueños_id_seq    SEQUENCE     �   CREATE SEQUENCE public."dueños_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."dueños_id_seq";
       public               postgres    false    234            �           0    0    dueños_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."dueños_id_seq" OWNED BY public."dueños".id;
          public               postgres    false    233            �            1259    16626    mantenimientos    TABLE     �  CREATE TABLE public.mantenimientos (
    id integer NOT NULL,
    unidad_id integer,
    tipo character varying(20) NOT NULL,
    estado character varying(20) DEFAULT 'PENDIENTE'::character varying,
    fecha_solicitud timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_realizacion timestamp without time zone,
    observaciones text,
    kilometraje_actual integer DEFAULT 0 NOT NULL,
    CONSTRAINT mantenimientos_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'REALIZADO'::character varying])::text[]))),
    CONSTRAINT mantenimientos_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['PREVENTIVO'::character varying, 'CORRECTIVO'::character varying])::text[])))
);
 "   DROP TABLE public.mantenimientos;
       public         heap r       postgres    false            �            1259    16625    mantenimientos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mantenimientos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.mantenimientos_id_seq;
       public               postgres    false    226            �           0    0    mantenimientos_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.mantenimientos_id_seq OWNED BY public.mantenimientos.id;
          public               postgres    false    225            �            1259    16611 
   materiales    TABLE       CREATE TABLE public.materiales (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    stock integer DEFAULT 0,
    precio numeric(10,2),
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT materiales_precio_check CHECK ((precio >= (0)::numeric)),
    CONSTRAINT materiales_stock_check CHECK ((stock >= 0))
);
    DROP TABLE public.materiales;
       public         heap r       postgres    false            �            1259    16610    materiales_id_seq    SEQUENCE     �   CREATE SEQUENCE public.materiales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.materiales_id_seq;
       public               postgres    false    224            �           0    0    materiales_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.materiales_id_seq OWNED BY public.materiales.id;
          public               postgres    false    223            �            1259    16685    partes_unidades    TABLE     �   CREATE TABLE public.partes_unidades (
    id integer NOT NULL,
    unidad_id integer,
    nombre character varying(100) NOT NULL,
    kilometraje_mantenimiento integer NOT NULL,
    ultimo_mantenimiento_km integer DEFAULT 0
);
 #   DROP TABLE public.partes_unidades;
       public         heap r       postgres    false            �            1259    16684    partes_unidades_id_seq    SEQUENCE     �   CREATE SEQUENCE public.partes_unidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.partes_unidades_id_seq;
       public               postgres    false    230            �           0    0    partes_unidades_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.partes_unidades_id_seq OWNED BY public.partes_unidades.id;
          public               postgres    false    229            �            1259    16593    unidades    TABLE     6  CREATE TABLE public.unidades (
    id integer NOT NULL,
    placa character varying(20) NOT NULL,
    modelo character varying(100),
    "año" integer,
    tipo character varying(50),
    chofer_id integer,
    kilometraje integer DEFAULT 0,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    dueno_id integer,
    CONSTRAINT "unidades_año_check" CHECK (("año" >= 2000)),
    CONSTRAINT unidades_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['BUS'::character varying, 'CARGA'::character varying, 'MINIVAN'::character varying])::text[])))
);
    DROP TABLE public.unidades;
       public         heap r       postgres    false            �            1259    16592    unidades_id_seq    SEQUENCE     �   CREATE SEQUENCE public.unidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.unidades_id_seq;
       public               postgres    false    222            �           0    0    unidades_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.unidades_id_seq OWNED BY public.unidades.id;
          public               postgres    false    221            �            1259    16563    usuarios    TABLE     �  CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    correo character varying(100) NOT NULL,
    password text NOT NULL,
    rol character varying(20) NOT NULL,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true,
    CONSTRAINT usuarios_rol_check CHECK (((rol)::text = ANY ((ARRAY['ADMIN'::character varying, 'CHOFER'::character varying])::text[])))
);
    DROP TABLE public.usuarios;
       public         heap r       postgres    false            �            1259    16562    usuarios_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.usuarios_id_seq;
       public               postgres    false    218            �           0    0    usuarios_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;
          public               postgres    false    217            �           2604    16702    alertas_mantenimiento id    DEFAULT     �   ALTER TABLE ONLY public.alertas_mantenimiento ALTER COLUMN id SET DEFAULT nextval('public.alertas_mantenimiento_id_seq'::regclass);
 G   ALTER TABLE public.alertas_mantenimiento ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    232    231    232            �           2604    16579    choferes id    DEFAULT     j   ALTER TABLE ONLY public.choferes ALTER COLUMN id SET DEFAULT nextval('public.choferes_id_seq'::regclass);
 :   ALTER TABLE public.choferes ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    220    219    220            �           2604    16647    detalles_mantenimiento id    DEFAULT     �   ALTER TABLE ONLY public.detalles_mantenimiento ALTER COLUMN id SET DEFAULT nextval('public.detalles_mantenimiento_id_seq'::regclass);
 H   ALTER TABLE public.detalles_mantenimiento ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    227    228    228            �           2604    16736 	   duenos id    DEFAULT     f   ALTER TABLE ONLY public.duenos ALTER COLUMN id SET DEFAULT nextval('public.duenos_id_seq'::regclass);
 8   ALTER TABLE public.duenos ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    236    235    236            �           2604    16727 
   dueños id    DEFAULT     l   ALTER TABLE ONLY public."dueños" ALTER COLUMN id SET DEFAULT nextval('public."dueños_id_seq"'::regclass);
 ;   ALTER TABLE public."dueños" ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    234    233    234            �           2604    16629    mantenimientos id    DEFAULT     v   ALTER TABLE ONLY public.mantenimientos ALTER COLUMN id SET DEFAULT nextval('public.mantenimientos_id_seq'::regclass);
 @   ALTER TABLE public.mantenimientos ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    225    226    226            �           2604    16614    materiales id    DEFAULT     n   ALTER TABLE ONLY public.materiales ALTER COLUMN id SET DEFAULT nextval('public.materiales_id_seq'::regclass);
 <   ALTER TABLE public.materiales ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    224    223    224            �           2604    16688    partes_unidades id    DEFAULT     x   ALTER TABLE ONLY public.partes_unidades ALTER COLUMN id SET DEFAULT nextval('public.partes_unidades_id_seq'::regclass);
 A   ALTER TABLE public.partes_unidades ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    229    230    230            �           2604    16596    unidades id    DEFAULT     j   ALTER TABLE ONLY public.unidades ALTER COLUMN id SET DEFAULT nextval('public.unidades_id_seq'::regclass);
 :   ALTER TABLE public.unidades ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    222    221    222            �           2604    16566    usuarios id    DEFAULT     j   ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);
 :   ALTER TABLE public.usuarios ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    217    218    218            u          0    16699    alertas_mantenimiento 
   TABLE DATA           d   COPY public.alertas_mantenimiento (id, unidad_id, parte_id, mensaje, estado, creado_en) FROM stdin;
    public               postgres    false    232   (}       i          0    16576    choferes 
   TABLE DATA           Q   COPY public.choferes (id, usuario_id, licencia, telefono, creado_en) FROM stdin;
    public               postgres    false    220   E}       q          0    16644    detalles_mantenimiento 
   TABLE DATA           j   COPY public.detalles_mantenimiento (id, mantenimiento_id, material_id, cantidad, costo_total) FROM stdin;
    public               postgres    false    228   �}       y          0    16733    duenos 
   TABLE DATA           E   COPY public.duenos (id, nombre, apellido, dni, contacto) FROM stdin;
    public               postgres    false    236   �}       w          0    16724    dueños 
   TABLE DATA           H   COPY public."dueños" (id, nombre, apellido, dni, contacto) FROM stdin;
    public               postgres    false    234   �}       o          0    16626    mantenimientos 
   TABLE DATA           �   COPY public.mantenimientos (id, unidad_id, tipo, estado, fecha_solicitud, fecha_realizacion, observaciones, kilometraje_actual) FROM stdin;
    public               postgres    false    226   �}       m          0    16611 
   materiales 
   TABLE DATA           W   COPY public.materiales (id, nombre, descripcion, stock, precio, creado_en) FROM stdin;
    public               postgres    false    224   �~       s          0    16685    partes_unidades 
   TABLE DATA           t   COPY public.partes_unidades (id, unidad_id, nombre, kilometraje_mantenimiento, ultimo_mantenimiento_km) FROM stdin;
    public               postgres    false    230          k          0    16593    unidades 
   TABLE DATA           p   COPY public.unidades (id, placa, modelo, "año", tipo, chofer_id, kilometraje, creado_en, dueno_id) FROM stdin;
    public               postgres    false    222   U       g          0    16563    usuarios 
   TABLE DATA           X   COPY public.usuarios (id, nombre, correo, password, rol, creado_en, activo) FROM stdin;
    public               postgres    false    218   �       �           0    0    alertas_mantenimiento_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.alertas_mantenimiento_id_seq', 1, false);
          public               postgres    false    231            �           0    0    choferes_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.choferes_id_seq', 1, true);
          public               postgres    false    219            �           0    0    detalles_mantenimiento_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.detalles_mantenimiento_id_seq', 1, true);
          public               postgres    false    227            �           0    0    duenos_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.duenos_id_seq', 1, false);
          public               postgres    false    235            �           0    0    dueños_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."dueños_id_seq"', 1, false);
          public               postgres    false    233            �           0    0    mantenimientos_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.mantenimientos_id_seq', 2, true);
          public               postgres    false    225            �           0    0    materiales_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.materiales_id_seq', 2, true);
          public               postgres    false    223            �           0    0    partes_unidades_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.partes_unidades_id_seq', 1, true);
          public               postgres    false    229            �           0    0    unidades_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.unidades_id_seq', 3, true);
          public               postgres    false    221            �           0    0    usuarios_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.usuarios_id_seq', 3, true);
          public               postgres    false    217            �           2606    16709 0   alertas_mantenimiento alertas_mantenimiento_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.alertas_mantenimiento
    ADD CONSTRAINT alertas_mantenimiento_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.alertas_mantenimiento DROP CONSTRAINT alertas_mantenimiento_pkey;
       public                 postgres    false    232            �           2606    16586    choferes choferes_licencia_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.choferes
    ADD CONSTRAINT choferes_licencia_key UNIQUE (licencia);
 H   ALTER TABLE ONLY public.choferes DROP CONSTRAINT choferes_licencia_key;
       public                 postgres    false    220            �           2606    16582    choferes choferes_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.choferes
    ADD CONSTRAINT choferes_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.choferes DROP CONSTRAINT choferes_pkey;
       public                 postgres    false    220            �           2606    16584     choferes choferes_usuario_id_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.choferes
    ADD CONSTRAINT choferes_usuario_id_key UNIQUE (usuario_id);
 J   ALTER TABLE ONLY public.choferes DROP CONSTRAINT choferes_usuario_id_key;
       public                 postgres    false    220            �           2606    16651 2   detalles_mantenimiento detalles_mantenimiento_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.detalles_mantenimiento
    ADD CONSTRAINT detalles_mantenimiento_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.detalles_mantenimiento DROP CONSTRAINT detalles_mantenimiento_pkey;
       public                 postgres    false    228            �           2606    16740    duenos duenos_dni_key 
   CONSTRAINT     O   ALTER TABLE ONLY public.duenos
    ADD CONSTRAINT duenos_dni_key UNIQUE (dni);
 ?   ALTER TABLE ONLY public.duenos DROP CONSTRAINT duenos_dni_key;
       public                 postgres    false    236            �           2606    16738    duenos duenos_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.duenos
    ADD CONSTRAINT duenos_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.duenos DROP CONSTRAINT duenos_pkey;
       public                 postgres    false    236            �           2606    16731    dueños dueños_dni_key 
   CONSTRAINT     U   ALTER TABLE ONLY public."dueños"
    ADD CONSTRAINT "dueños_dni_key" UNIQUE (dni);
 E   ALTER TABLE ONLY public."dueños" DROP CONSTRAINT "dueños_dni_key";
       public                 postgres    false    234            �           2606    16729    dueños dueños_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public."dueños"
    ADD CONSTRAINT "dueños_pkey" PRIMARY KEY (id);
 B   ALTER TABLE ONLY public."dueños" DROP CONSTRAINT "dueños_pkey";
       public                 postgres    false    234            �           2606    16637 "   mantenimientos mantenimientos_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.mantenimientos
    ADD CONSTRAINT mantenimientos_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.mantenimientos DROP CONSTRAINT mantenimientos_pkey;
       public                 postgres    false    226            �           2606    16624     materiales materiales_nombre_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.materiales
    ADD CONSTRAINT materiales_nombre_key UNIQUE (nombre);
 J   ALTER TABLE ONLY public.materiales DROP CONSTRAINT materiales_nombre_key;
       public                 postgres    false    224            �           2606    16622    materiales materiales_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.materiales
    ADD CONSTRAINT materiales_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.materiales DROP CONSTRAINT materiales_pkey;
       public                 postgres    false    224            �           2606    16691 $   partes_unidades partes_unidades_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.partes_unidades
    ADD CONSTRAINT partes_unidades_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.partes_unidades DROP CONSTRAINT partes_unidades_pkey;
       public                 postgres    false    230            �           2606    16602    unidades unidades_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT unidades_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.unidades DROP CONSTRAINT unidades_pkey;
       public                 postgres    false    222            �           2606    16604    unidades unidades_placa_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT unidades_placa_key UNIQUE (placa);
 E   ALTER TABLE ONLY public.unidades DROP CONSTRAINT unidades_placa_key;
       public                 postgres    false    222            �           2606    16574    usuarios usuarios_correo_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_correo_key UNIQUE (correo);
 F   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuarios_correo_key;
       public                 postgres    false    218            �           2606    16572    usuarios usuarios_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuarios_pkey;
       public                 postgres    false    218            �           1259    16681    idx_chofer_unidad    INDEX     K   CREATE INDEX idx_chofer_unidad ON public.unidades USING btree (chofer_id);
 %   DROP INDEX public.idx_chofer_unidad;
       public                 postgres    false    222            �           1259    16682    idx_mantenimiento_unidad    INDEX     X   CREATE INDEX idx_mantenimiento_unidad ON public.mantenimientos USING btree (unidad_id);
 ,   DROP INDEX public.idx_mantenimiento_unidad;
       public                 postgres    false    226            �           2620    16663 ,   detalles_mantenimiento trigger_calculo_costo    TRIGGER     �   CREATE TRIGGER trigger_calculo_costo BEFORE INSERT OR UPDATE ON public.detalles_mantenimiento FOR EACH ROW EXECUTE FUNCTION public.calcular_costo_total();
 E   DROP TRIGGER trigger_calculo_costo ON public.detalles_mantenimiento;
       public               postgres    false    228    237            �           2606    16715 9   alertas_mantenimiento alertas_mantenimiento_parte_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alertas_mantenimiento
    ADD CONSTRAINT alertas_mantenimiento_parte_id_fkey FOREIGN KEY (parte_id) REFERENCES public.partes_unidades(id) ON DELETE CASCADE;
 c   ALTER TABLE ONLY public.alertas_mantenimiento DROP CONSTRAINT alertas_mantenimiento_parte_id_fkey;
       public               postgres    false    232    230    4800            �           2606    16710 :   alertas_mantenimiento alertas_mantenimiento_unidad_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alertas_mantenimiento
    ADD CONSTRAINT alertas_mantenimiento_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidades(id) ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.alertas_mantenimiento DROP CONSTRAINT alertas_mantenimiento_unidad_id_fkey;
       public               postgres    false    232    4787    222            �           2606    16587 !   choferes choferes_usuario_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.choferes
    ADD CONSTRAINT choferes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.choferes DROP CONSTRAINT choferes_usuario_id_fkey;
       public               postgres    false    220    4778    218            �           2606    16652 C   detalles_mantenimiento detalles_mantenimiento_mantenimiento_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalles_mantenimiento
    ADD CONSTRAINT detalles_mantenimiento_mantenimiento_id_fkey FOREIGN KEY (mantenimiento_id) REFERENCES public.mantenimientos(id) ON DELETE CASCADE;
 m   ALTER TABLE ONLY public.detalles_mantenimiento DROP CONSTRAINT detalles_mantenimiento_mantenimiento_id_fkey;
       public               postgres    false    228    4796    226            �           2606    16657 >   detalles_mantenimiento detalles_mantenimiento_material_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalles_mantenimiento
    ADD CONSTRAINT detalles_mantenimiento_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materiales(id) ON DELETE CASCADE;
 h   ALTER TABLE ONLY public.detalles_mantenimiento DROP CONSTRAINT detalles_mantenimiento_material_id_fkey;
       public               postgres    false    228    4793    224            �           2606    16741    unidades fk_dueno    FK CONSTRAINT     �   ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT fk_dueno FOREIGN KEY (dueno_id) REFERENCES public.duenos(id) ON DELETE SET NULL;
 ;   ALTER TABLE ONLY public.unidades DROP CONSTRAINT fk_dueno;
       public               postgres    false    222    236    4810            �           2606    16638 ,   mantenimientos mantenimientos_unidad_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mantenimientos
    ADD CONSTRAINT mantenimientos_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidades(id) ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.mantenimientos DROP CONSTRAINT mantenimientos_unidad_id_fkey;
       public               postgres    false    4787    222    226            �           2606    16692 .   partes_unidades partes_unidades_unidad_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.partes_unidades
    ADD CONSTRAINT partes_unidades_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidades(id) ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.partes_unidades DROP CONSTRAINT partes_unidades_unidad_id_fkey;
       public               postgres    false    4787    230    222            �           2606    16605     unidades unidades_chofer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT unidades_chofer_id_fkey FOREIGN KEY (chofer_id) REFERENCES public.choferes(id) ON DELETE SET NULL;
 J   ALTER TABLE ONLY public.unidades DROP CONSTRAINT unidades_chofer_id_fkey;
       public               postgres    false    220    4782    222            u      x������ � �      i   ;   x��K�0�3�����.�����3.��`d��;]����� �� vgU�~[U$
!      q      x�3�4BSN3=�=... r�      y      x������ � �      w      x������ � �      o   �   x���1�  ��s
.P���Y��mөZ4-��^�#x1�'p{ӓ ������Z�?5���PURqi,�V+��]����K�|�<\czF�(�^��, ��Y��P���qKkz���{+q��~��1��+*      m   �   x�}�1! ��|����\gc�l���܃,}�}L����)f,�`�Y���۵I������?��
�`Dp�hB?Y�mXp^�r!Ь�d�~bQ����%Ǧ���Gg��+x��۽��$W/�      s   &   x�3�4�t��))�WHIUH�,J�44 N�=... �Gt      k   {   x�]�;�0�z}
_��~���SC�@�wQ")�'	S�f��������Ug[��Ff(��gP\�5�P���1d����uc���m�6�d���Ȏп��1堾��r܌�c�C��      g   �   x�m��N�0�盧Ȑ��ڮ�뉴-?mR���6�T;�]�7�9x1��*��9ç�PHK۸��7��t�����y49�jjSv:���%e���n�� �PS�p�'�I)�p���T��g�k\;hп�;a��b�WE����WKQ��|�+-�u἟���Ff�e]�3���j0TC������w=����f��1wfL��n�����&�͞/�L�L	I���9T�+���( \     