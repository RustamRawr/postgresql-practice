--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: add_game_item(character, character varying, character, character, integer, character, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_game_item(item_name character, item_description character varying, item_rarity character, item_type character, item_price integer, item_main_attribute character, item_weight numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_item_id INTEGER;
BEGIN
    INSERT INTO game_items (name, description, rarity, item_type, price, main_attribute, weight)
    VALUES (item_name, item_description, item_rarity, item_type, item_price, item_main_attribute, item_weight)
    RETURNING item_id INTO new_item_id;

    RETURN new_item_id;
END;
$$;


ALTER FUNCTION public.add_game_item(item_name character, item_description character varying, item_rarity character, item_type character, item_price integer, item_main_attribute character, item_weight numeric) OWNER TO postgres;

--
-- Name: get_quests_by_location(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_quests_by_location(location_id_param integer) RETURNS TABLE(quest_id integer, name character, description character varying, task_type character, difficulty_level character, rewards character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT quests.quest_id, quests.name, quests.description, quests.task_type, quests.difficulty_level, quests.rewards
    FROM quests
    WHERE location_id = location_id_param;
END;
$$;


ALTER FUNCTION public.get_quests_by_location(location_id_param integer) OWNER TO postgres;

--
-- Name: log_deleted_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_deleted_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO deleted_data_log(table_name, deleted_id, deleted_at)
    VALUES (TG_TABLE_NAME, OLD.item_id, current_timestamp);

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.log_deleted_data() OWNER TO postgres;

--
-- Name: log_player_login_time(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_player_login_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO time_of_creation_new_pc (pc_id, login_time)
    VALUES (NEW.pc_id, NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_player_login_time() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievements (
    achievement_id integer NOT NULL,
    quest_id integer NOT NULL,
    name character(40) NOT NULL,
    description character varying NOT NULL,
    rewards character varying,
    quest_unlock character varying
);


ALTER TABLE public.achievements OWNER TO postgres;

--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.achievements_achievement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.achievements_achievement_id_seq OWNER TO postgres;

--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.achievements_achievement_id_seq OWNED BY public.achievements.achievement_id;


--
-- Name: achievements_quest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.achievements_quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.achievements_quest_id_seq OWNER TO postgres;

--
-- Name: achievements_quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.achievements_quest_id_seq OWNED BY public.achievements.quest_id;


--
-- Name: npc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.npc (
    npc_id integer NOT NULL,
    location_id integer NOT NULL,
    name character(30) NOT NULL,
    level integer NOT NULL,
    race character(15),
    class character(20),
    characteristics character varying NOT NULL,
    equipment character varying,
    is_story_npc boolean NOT NULL,
    relationship_to_player integer
);


ALTER TABLE public.npc OWNER TO postgres;

--
-- Name: player_character; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_character (
    pc_id integer NOT NULL,
    name character(55) NOT NULL,
    level integer NOT NULL,
    race character(15) NOT NULL,
    class character(20) NOT NULL,
    characteristics character varying NOT NULL,
    equipment character varying,
    unique_ability character(35)
);


ALTER TABLE public.player_character OWNER TO postgres;

--
-- Name: all_characters; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.all_characters AS
 SELECT player_character.name
   FROM public.player_character
UNION
 SELECT npc.name
   FROM public.npc;


ALTER VIEW public.all_characters OWNER TO postgres;

--
-- Name: current_game_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_game_statistics (
    progress_id integer NOT NULL,
    pc_id integer NOT NULL,
    quest_id integer NOT NULL,
    achievement_id integer NOT NULL,
    location_id integer NOT NULL,
    login_time timestamp without time zone NOT NULL,
    logout_time timestamp without time zone NOT NULL
);


ALTER TABLE public.current_game_statistics OWNER TO postgres;

--
-- Name: current_quests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_quests (
    current_quests_id integer NOT NULL,
    quest_id integer NOT NULL,
    pc_id integer NOT NULL
);


ALTER TABLE public.current_quests OWNER TO postgres;

--
-- Name: deleted_data_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deleted_data_log (
    table_name text,
    deleted_id integer,
    deleted_at timestamp without time zone
);


ALTER TABLE public.deleted_data_log OWNER TO postgres;

--
-- Name: game_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_items (
    item_id integer NOT NULL,
    name character(65) NOT NULL,
    description character varying,
    rarity character(20),
    item_type character(20) NOT NULL,
    price integer,
    main_attribute character(20),
    weight numeric NOT NULL
);


ALTER TABLE public.game_items OWNER TO postgres;

--
-- Name: game_items_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.game_items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.game_items_item_id_seq OWNER TO postgres;

--
-- Name: game_items_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.game_items_item_id_seq OWNED BY public.game_items.item_id;


--
-- Name: item_prices; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.item_prices AS
 SELECT name,
    price
   FROM public.game_items;


ALTER VIEW public.item_prices OWNER TO postgres;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    location_id integer NOT NULL,
    name character(40),
    description character varying,
    available_quests character varying,
    location_type character(30),
    domain character(15)
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- Name: locations_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_location_id_seq OWNER TO postgres;

--
-- Name: locations_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_location_id_seq OWNED BY public.locations.location_id;


--
-- Name: npc_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.npc_inventory (
    npc_inventory_id integer NOT NULL,
    npc_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer NOT NULL
);


ALTER TABLE public.npc_inventory OWNER TO postgres;

--
-- Name: npc_inventory_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_inventory_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_inventory_item_id_seq OWNER TO postgres;

--
-- Name: npc_inventory_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_inventory_item_id_seq OWNED BY public.npc_inventory.item_id;


--
-- Name: npc_inventory_npc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_inventory_npc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_inventory_npc_id_seq OWNER TO postgres;

--
-- Name: npc_inventory_npc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_inventory_npc_id_seq OWNED BY public.npc_inventory.npc_id;


--
-- Name: npc_inventory_npc_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_inventory_npc_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_inventory_npc_inventory_id_seq OWNER TO postgres;

--
-- Name: npc_inventory_npc_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_inventory_npc_inventory_id_seq OWNED BY public.npc_inventory.npc_inventory_id;


--
-- Name: npc_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_location_id_seq OWNER TO postgres;

--
-- Name: npc_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_location_id_seq OWNED BY public.npc.location_id;


--
-- Name: npc_npc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_npc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_npc_id_seq OWNER TO postgres;

--
-- Name: npc_npc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_npc_id_seq OWNED BY public.npc.npc_id;


--
-- Name: npc_quests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.npc_quests (
    npc_quests_id integer NOT NULL,
    npc_id integer NOT NULL,
    quest_id integer NOT NULL
);


ALTER TABLE public.npc_quests OWNER TO postgres;

--
-- Name: npc_quests_npc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_quests_npc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_quests_npc_id_seq OWNER TO postgres;

--
-- Name: npc_quests_npc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_quests_npc_id_seq OWNED BY public.npc_quests.npc_id;


--
-- Name: npc_quests_npc_quests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_quests_npc_quests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_quests_npc_quests_id_seq OWNER TO postgres;

--
-- Name: npc_quests_npc_quests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_quests_npc_quests_id_seq OWNED BY public.npc_quests.npc_quests_id;


--
-- Name: npc_quests_quest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npc_quests_quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npc_quests_quest_id_seq OWNER TO postgres;

--
-- Name: npc_quests_quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npc_quests_quest_id_seq OWNED BY public.npc_quests.quest_id;


--
-- Name: player_character_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_character_pc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_character_pc_id_seq OWNER TO postgres;

--
-- Name: player_character_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_character_pc_id_seq OWNED BY public.player_character.pc_id;


--
-- Name: player_character_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.player_character_view AS
 SELECT pc_id,
    name,
    level,
    race,
    class
   FROM public.player_character;


ALTER VIEW public.player_character_view OWNER TO postgres;

--
-- Name: player_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_inventory (
    player_inventory_id integer NOT NULL,
    pc_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer
);


ALTER TABLE public.player_inventory OWNER TO postgres;

--
-- Name: player_inventory_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_inventory_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_inventory_item_id_seq OWNER TO postgres;

--
-- Name: player_inventory_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_inventory_item_id_seq OWNED BY public.player_inventory.item_id;


--
-- Name: player_inventory_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_inventory_pc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_inventory_pc_id_seq OWNER TO postgres;

--
-- Name: player_inventory_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_inventory_pc_id_seq OWNED BY public.player_inventory.pc_id;


--
-- Name: player_inventory_player_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_inventory_player_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_inventory_player_inventory_id_seq OWNER TO postgres;

--
-- Name: player_inventory_player_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_inventory_player_inventory_id_seq OWNED BY public.player_inventory.player_inventory_id;


--
-- Name: player_progress_achievement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_progress_achievement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_progress_achievement_id_seq OWNER TO postgres;

--
-- Name: player_progress_achievement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_progress_achievement_id_seq OWNED BY public.current_game_statistics.achievement_id;


--
-- Name: player_progress_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_progress_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_progress_location_id_seq OWNER TO postgres;

--
-- Name: player_progress_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_progress_location_id_seq OWNED BY public.current_game_statistics.location_id;


--
-- Name: player_progress_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_progress_pc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_progress_pc_id_seq OWNER TO postgres;

--
-- Name: player_progress_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_progress_pc_id_seq OWNED BY public.current_game_statistics.pc_id;


--
-- Name: player_progress_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_progress_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_progress_progress_id_seq OWNER TO postgres;

--
-- Name: player_progress_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_progress_progress_id_seq OWNED BY public.current_game_statistics.progress_id;


--
-- Name: player_progress_quest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_progress_quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_progress_quest_id_seq OWNER TO postgres;

--
-- Name: player_progress_quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_progress_quest_id_seq OWNED BY public.current_game_statistics.quest_id;


--
-- Name: quests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quests (
    quest_id integer NOT NULL,
    location_id integer NOT NULL,
    name character(60) NOT NULL,
    description character varying NOT NULL,
    task_type character(30) NOT NULL,
    difficulty_level character(30),
    rewards character varying
);


ALTER TABLE public.quests OWNER TO postgres;

--
-- Name: quests_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quests_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quests_location_id_seq OWNER TO postgres;

--
-- Name: quests_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quests_location_id_seq OWNED BY public.quests.location_id;


--
-- Name: quests_player_characters_pc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quests_player_characters_pc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quests_player_characters_pc_id_seq OWNER TO postgres;

--
-- Name: quests_player_characters_pc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quests_player_characters_pc_id_seq OWNED BY public.current_quests.pc_id;


--
-- Name: quests_player_characters_quest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quests_player_characters_quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quests_player_characters_quest_id_seq OWNER TO postgres;

--
-- Name: quests_player_characters_quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quests_player_characters_quest_id_seq OWNED BY public.current_quests.quest_id;


--
-- Name: quests_player_characters_quests_player_ch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quests_player_characters_quests_player_ch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quests_player_characters_quests_player_ch_id_seq OWNER TO postgres;

--
-- Name: quests_player_characters_quests_player_ch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quests_player_characters_quests_player_ch_id_seq OWNED BY public.current_quests.current_quests_id;


--
-- Name: quests_quest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quests_quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quests_quest_id_seq OWNER TO postgres;

--
-- Name: quests_quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quests_quest_id_seq OWNED BY public.quests.quest_id;


--
-- Name: time_of_creation_new_pc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.time_of_creation_new_pc (
    pc_id integer,
    login_time timestamp without time zone
);


ALTER TABLE public.time_of_creation_new_pc OWNER TO postgres;

--
-- Name: achievements achievement_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements ALTER COLUMN achievement_id SET DEFAULT nextval('public.achievements_achievement_id_seq'::regclass);


--
-- Name: achievements quest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements ALTER COLUMN quest_id SET DEFAULT nextval('public.achievements_quest_id_seq'::regclass);


--
-- Name: current_game_statistics progress_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics ALTER COLUMN progress_id SET DEFAULT nextval('public.player_progress_progress_id_seq'::regclass);


--
-- Name: current_game_statistics pc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics ALTER COLUMN pc_id SET DEFAULT nextval('public.player_progress_pc_id_seq'::regclass);


--
-- Name: current_game_statistics quest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics ALTER COLUMN quest_id SET DEFAULT nextval('public.player_progress_quest_id_seq'::regclass);


--
-- Name: current_game_statistics achievement_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics ALTER COLUMN achievement_id SET DEFAULT nextval('public.player_progress_achievement_id_seq'::regclass);


--
-- Name: current_game_statistics location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics ALTER COLUMN location_id SET DEFAULT nextval('public.player_progress_location_id_seq'::regclass);


--
-- Name: current_quests current_quests_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests ALTER COLUMN current_quests_id SET DEFAULT nextval('public.quests_player_characters_quests_player_ch_id_seq'::regclass);


--
-- Name: current_quests quest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests ALTER COLUMN quest_id SET DEFAULT nextval('public.quests_player_characters_quest_id_seq'::regclass);


--
-- Name: current_quests pc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests ALTER COLUMN pc_id SET DEFAULT nextval('public.quests_player_characters_pc_id_seq'::regclass);


--
-- Name: game_items item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_items ALTER COLUMN item_id SET DEFAULT nextval('public.game_items_item_id_seq'::regclass);


--
-- Name: locations location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN location_id SET DEFAULT nextval('public.locations_location_id_seq'::regclass);


--
-- Name: npc npc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc ALTER COLUMN npc_id SET DEFAULT nextval('public.npc_npc_id_seq'::regclass);


--
-- Name: npc location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc ALTER COLUMN location_id SET DEFAULT nextval('public.npc_location_id_seq'::regclass);


--
-- Name: npc_inventory npc_inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory ALTER COLUMN npc_inventory_id SET DEFAULT nextval('public.npc_inventory_npc_inventory_id_seq'::regclass);


--
-- Name: npc_inventory npc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory ALTER COLUMN npc_id SET DEFAULT nextval('public.npc_inventory_npc_id_seq'::regclass);


--
-- Name: npc_inventory item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory ALTER COLUMN item_id SET DEFAULT nextval('public.npc_inventory_item_id_seq'::regclass);


--
-- Name: npc_quests npc_quests_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests ALTER COLUMN npc_quests_id SET DEFAULT nextval('public.npc_quests_npc_quests_id_seq'::regclass);


--
-- Name: npc_quests npc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests ALTER COLUMN npc_id SET DEFAULT nextval('public.npc_quests_npc_id_seq'::regclass);


--
-- Name: npc_quests quest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests ALTER COLUMN quest_id SET DEFAULT nextval('public.npc_quests_quest_id_seq'::regclass);


--
-- Name: player_character pc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_character ALTER COLUMN pc_id SET DEFAULT nextval('public.player_character_pc_id_seq'::regclass);


--
-- Name: player_inventory player_inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory ALTER COLUMN player_inventory_id SET DEFAULT nextval('public.player_inventory_player_inventory_id_seq'::regclass);


--
-- Name: player_inventory pc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory ALTER COLUMN pc_id SET DEFAULT nextval('public.player_inventory_pc_id_seq'::regclass);


--
-- Name: player_inventory item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory ALTER COLUMN item_id SET DEFAULT nextval('public.player_inventory_item_id_seq'::regclass);


--
-- Name: quests quest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quests ALTER COLUMN quest_id SET DEFAULT nextval('public.quests_quest_id_seq'::regclass);


--
-- Name: quests location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quests ALTER COLUMN location_id SET DEFAULT nextval('public.quests_location_id_seq'::regclass);


--
-- Data for Name: achievements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.achievements (achievement_id, quest_id, name, description, rewards, quest_unlock) FROM stdin;
1	1	С лёгким паром!                         	Успешно пройти первую локацию и не умереть.	Опыт:100	'Поиск Затерянного Храма'
2	2	Раскрыватель тайн                       	Любопытство приводит к открытию тайн исчезновения жителей деревни.	Опыт:150	\N
3	4	Любопытный наблюдатель                  	Вы нашли пасхальную желейку!	Опыт:250	\N
4	3	Исследователь Подземий                  	Смелость и решительность ведут вас в темные подземные катакомбы, и вы без потерь выбираетесь оттуда	Опыт:100	\N
5	4	Искатель древности                      	Ваш поиск древнего храма приводит к сокровищам забытого прошлого.	Опыт:200	\N
6	5	Разгадыватель загадок                   	Тщательное расследование поражает разгадкой пропавшего груза, окутанного мистическими тайнами.	Опыт:200	\N
7	6	Покоритель тайных храмов                	Познание зловещей тайны древнего храма приводит к страшным открытиям.	Опыт:200	\N
8	7	Спаситель магистра                      	Сильное чувство опеки благотворно ведет к спасению пропавшего магистра.	Опыт:100	\N
9	8	Защитник крепости                       	Верность обороне Каменной Крепости Каргимар принесет славу своим героям	Опыт:350	\N
10	11	Мастер пещерных глубин                  	Смелость и мастерство привели к подчинению Хищника Глубин	Опыт:350	\N
11	1	Создатель                               	Создайте своего первого персонажа.	Опыт:50	Выбраться из Альвадара
\.


--
-- Data for Name: current_game_statistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_game_statistics (progress_id, pc_id, quest_id, achievement_id, location_id, login_time, logout_time) FROM stdin;
1	1	3	1	3	2024-06-15 10:02:04	2024-06-15 12:35:23
2	2	1	11	1	2024-05-15 10:24:04	2024-05-15 12:30:20
3	3	4	3	4	2024-05-16 11:24:54	2024-05-16 13:23:23
4	4	2	1	2	2024-05-17 20:34:55	2024-05-17 22:35:02
5	5	8	4	8	2024-04-18 18:45:12	2024-04-18 20:23:49
6	6	7	3	7	2024-04-20 19:56:45	2024-04-20 20:40:51
7	7	1	11	1	2024-04-22 09:16:01	2024-04-22 12:30:00
8	8	10	6	10	2024-03-23 09:46:12	2024-03-23 13:01:11
9	9	5	4	5	2024-03-24 17:56:45	2024-03-24 19:55:08
10	10	11	10	11	2024-03-09 19:32:16	2024-03-09 20:01:42
\.


--
-- Data for Name: current_quests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_quests (current_quests_id, quest_id, pc_id) FROM stdin;
1	3	1
2	1	2
3	4	3
4	2	4
5	8	5
6	6	5
7	7	6
8	1	7
9	10	8
10	5	9
11	10	9
12	11	10
13	9	10
\.


--
-- Data for Name: deleted_data_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deleted_data_log (table_name, deleted_id, deleted_at) FROM stdin;
game_items	42	2024-06-13 21:45:11.998274
game_items	44	2024-06-14 19:33:05.350176
\.


--
-- Data for Name: game_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.game_items (item_id, name, description, rarity, item_type, price, main_attribute, weight) FROM stdin;
3	Круг термофильного сыра                                          	Этот необычный объект выглядит как идеально круглый сыр с золотисто-жёлтой корочкой, излучающий легкое сияние.	Мистический         	Еда                 	150	\N	1.00
4	Средние зелье здоровья                                           	Это загадочное зелье, созданное мудрыми алхимиками в древние времена, излучает тусклое сияние красноватого оттенка. Его жидкость колышется внутри прозрачной бутыли, словно живая сущность, и излучает тонкий неуловимый аромат	Редкий              	Зелья               	50	\N	0.50
5	Пакет документов для клана                                       	Этот запечатанный конверт с клановой печатью словно наполнен десятком бумаг, Редрик уведомил, что открывать его не стоит	Необычный, Сюжетный 	Письма              	\N	\N	0.05
6	Льняное одеяние с верёвками                                      	Эта льняная одежда — символ силы и упорства. Все, кто одет в это льняное одеяние, обретают уверенность в своих действиях и готовы преодолевать любые преграды на своем пути.	Обычный             	Одежда              	100	\N	2.5
7	Серебряное кольцо сколоченного якоря                             	Любимое кольцо Редрика Младшего, которое он всегда носит на указательном пальце	Уникальный          	Кольцо              	250	\N	0.05
8	Топорик                                                          	Хорошо заточенный топорик, пригодится на все случаи жизни - от бытовых задач до сражений	Обычный             	Оружие              	50	\N	3.50
9	Яблоко Вечной Сладости                                           	Сияющее яблоко с невероятно сладким вкусом, которое дарует тому, кто съест его, необычайную выносливость и энергию.	Редкий              	Еда                 	100	\N	0.30
10	Эликсир Живой Воды                                               	Уникальный эликсир, изготовленный из древних зеленых растений, который способен восстановить здоровье и силы в самый критический момент.	Эпический           	Зелья               	200	\N	0.40
11	Письмо Зловещего Пророчества                                     	Таинственное письмо, приносящее неутешительные предсказания о будущем. Владелец этого письма может встретить свою судьбу.	Необычный           	Письма              	80	\N	0.10
12	Стейк Дракона                                                    	Мясо дракона, приготовленное по древнему рецепту, обладает необычайным вкусом и приносит силу и мужество тому, кто осмелится его съесть.	Легендарный         	Еда                 	500	\N	0.80
13	Эликсир Временного Опустошения                                   	Это опасное зелье способно замедлить время для врагов, препятствуя им в их атаке. Однако его употребление накладывает на вас проклятие недвижимости.	Редкий              	Зелья               	150	\N	0.60
17	Кольцо Огненного пальца                                          	Кольцо, исполненное пламенем и дарующие носителю уверенность в своих действиях. Позволяет владельцу устраивать сражения с использованием огня	Легендарный         	Аксессуар           	350	\N	0.60
18	Сова Мудрости                                                    	Фигурка совы, дарующая своему обладателю мудрость и ясность мысли. Обладает способностью предсказывать опасность на пути.	Необычный           	Аксессуар           	200	\N	0.20
19	Книга Забытых знаний                                             	Старинная книга, хранящая знания о тысячи историй и загадок. Способна открыть свои страницы только тому, кто достоин ее мудрости.	Редкий              	Реликвия            	600	\N	1.20
20	Хвост Драконьего чудища                                          	Загадочный хвост дракона, который, как говорят, приносит удачу и защиту своему обладателю. Неизвестно, что можно с ним сделать, но много слухов об его могуществе.	Мифический          	Реликвия            	\N	\N	2.50
21	Медовый пирог с карамелью                                        	Аппетитный пирог, пропитанный сладким медом и покрытый ароматной карамелью.	Необычный           	Еда                 	120	\N	0.50
22	Экзотические фрукты светила                                      	Сочные и яркие фрукты, приносят свежесть и радость, исходящую непосредственно от солнца.	Редкий              	Еда                 	150	\N	0.40
23	Тропический улиточный деликатес                                  	Редкий деликатес из тропических улиток, неповторимого вкуса и уникальных питательных свойств.	Эпический           	Еда                 	200	\N	0.60
24	Пламенная лапша с перчиком чили                                  	Острое блюдо с лапшой в соусе и пламенным чили с сочным мясом.	Редкий              	Еда                 	160	\N	0.45
26	Подозрительный элексир манго                                     	Загадочный напиток, извлеченный из спелых манго, который возвращает силы и придаёт радости.	Редкий              	Еда                 	180	\N	0.35
27	Золотой орех                                                     	Таинственный орех, обладающий силой легенд и способен даровать мудрость и прозорливость.	Эпический           	Еда                 	250	\N	0.70
28	Драконий жар паприки                                             	Острое блюдо, созданное из драконьей паприки, которая придает блюду не только огненную пикантность, но и потайные свойства.	Легендарный         	Еда                 	300	\N	0.80
29	Императорский кекс с изумрудной глазурью                         	Невероятно роскошный кекс, украшенный изящной изумрудной глазурью - любовь и гордость пекарского мастерства.	Легендарный         	Еда                 	350	\N	0.90
30	Подземное печенье-самоцвет                                       	Таинственное печенье, испеченное из древних ингредиентов с добавлением ценных самоцветов, обладает необъяснимым вкусом и силой самого Подземья.	Мифический          	Еда                 	400	\N	1.00
31	Кожаная куртка                                                   	Прочная кожаная куртка, обеспечивающая базовую защиту от ударов и осколков.	Обычный             	Броня               	50	\N	2.0
32	Бронзовые наручи                                                 	Наручи, изготовленные из прочного бронзового сплава, защищают руки и предплечья в бою.	Необычный           	Броня               	80	\N	1.5
33	Шерстяной плащ                                                   	Теплый и мягкий плащ из натуральной шерсти, обеспечивает комфорт в холодные ночи.	Обычный             	Одежда              	40	\N	1.0
34	Хлопковые штаны                                                  	Удобные штаны из мягкого хлопка, идеальны для повседневного использования.	Обычный             	Одежда              	30	\N	0.8
35	Стальной кастет                                                  	Прочный кастет с острыми краями, предназначенный для ближнего боя и нанесения сокрушительных ударов.	Редкий              	Оружие              	100	\N	1.0
36	Железные поножи                                                  	Надежные поножи из крепкого железа, защищают ноги и икроножные мышцы в сражении.	Необычный           	Броня               	70	\N	2.0
37	Хлопковая рубашка                                                	Простая рубашка из мягкого хлопка, обеспечивает свободу движений и комфорт в повседневной жизни.	Обычный             	Одежда              	35	\N	0.5
38	Легкая кожаная шапка                                             	Удобная шапка из легкой кожи, предназначена для защиты от солнца и небольших ударов.	Обычный             	Броня               	45	\N	0.3
39	Стальной кинжал                                                  	Острый и надежный кинжал с лезвием из закаленной стали, идеален для скрытных атак или боев на короткую дистанцию.	Необычный           	Оружие              	80	\N	0.8
40	Лютня Певчих сноведений                                          	Изысканный музыкальный инструмент, который способен вызывать мелодии, словно проплывающие сквозь сны и тени.	Редкий              	Аксессуар           	120	\N	1.0
25	Солнце и луна                                                    	Двойное блюдо, где сочетаются противоположности: острый соус и сладкие фрукты, создавая гармонию вкуса.	Необычный           	Еда                 	130	\N	0.55
43	Название предмета                                                	Описание предмета	Редкость предмета   	Тип предмета        	100	Основной атрибут    	0.5
45	Название предмета                                                	Описание предмета	Редкость предмета   	Тип предмета        	100	Основной атрибут    	0.5
46	Название предмета                                                	Описание предмета	Редкость предмета   	Тип предмета        	100	Основной атрибут    	0.5
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (location_id, name, description, available_quests, location_type, domain) FROM stdin;
1	Подземелье Альвадара                    	Руины старого городка, скрытые глубоко под земльёй, прекрасный анклав цивилизации Древних	Найти выход из древних руин	Подземелье                    	Домен Рексов   
2	Деревня Призрачного Мглистого Болота    	Таинственное поселение, окруженное густым туманом и мистической атмосферой, где обитают потусторонние существа	Раскрыть тайну исчезновения жителей	Деревня                       	Бездоменный    
3	Заброшенный Замок Боргстейн             	Старинное сооружение, покрытое паутиной и пеплом, таинственный символ мрачных времен, где скрываются проклятые тайны	Иследовать подземные катакомбы	Замок                         	Вууры          
4	Тёмный Лес Хрустальных Деревьев         	Мрачный лес, где стволы деревьев испускают ослепительно светящиеся слёзы, создавая ауру мистики и опасности	Найти древний храм в глубине леса	Лес                           	Древние        
5	Подземные Города Железного Рудника      	Сеть подземных поселений, вырубленных из каменных стен и механических устройств, где процветает торговля и производство	Разгадать загадку пропавшего груза	Подземной город               	Домен Рексов   
6	Равнины Искусителей                     	Широкие земли, покрытые мягкой травой и мистическими растениями, где обитают зловещие существа	Исследовать таинственный храм	Равнина                       	Бездоменный    
7	Город Серебряных Башен                  	Могучий город, выстроенный из блестящего кирпича, где царит безмятежность и единство с Небом	Найти пропавшего магистра	Город                         	Вууры          
8	Каменные Крепости Каргимар              	Неприступная крепость, возвышающаяся над обрывистым ущельем, являющиеся памятью о забытых историях военных подвигов Бравых	Оборонить крепость от нападения отступников	Замок                         	Домен Рексов   
9	Деревня Забытых Снов                    	Уединённое поселение среди тёмного леса, где жители защищены неизвестными силами и живут вечным сном	Разгадать загадку проклятия	Деревня                       	Желейный       
10	Глубины Чёрного Ключа                   	Мрачные подземелья с источниками неистовых вод, где скрываются таинства древних исторических исследований	Добыть артефакт Забытых Королей	Подземелье                    	Бездоменный    
11	Темная Пещера Ноктал                    	Подземный город, пронизанный сетью тёмных тоннелей и магмовых потоков, в который обитают монстры и разбойники	Спасти пленников из лап хищника-главаря	Подземный город               	Домен Рексов   
\.


--
-- Data for Name: npc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.npc (npc_id, location_id, name, level, race, class, characteristics, equipment, is_story_npc, relationship_to_player) FROM stdin;
1	1	Редрик Младший                	10	Андеррекс      	Воин                	Здоровье:156, Сила:21, Ловкость:12, Телосложение:22, Мудрость:16, Харизма:18	Льняное одеяние с верёвками, Топорик, Серебряное кольцо сколоченного якоря	t	65
2	11	Даргор Браак Златовласый      	8	Андеррекс      	Варвар              	Здоровье:134, Сила:19, Ловкость:14, Телосложение:20, Мудрость:10, Харизма:13	Кожаная броня Медвежьего рыка, Тяжелый боевой топор "Громовой Рёв", Наплечники Бесстрашного	f	42
3	10	Адрик Кровавый Клык           	6	Кседокс        	Жрец                	Здоровье:98, Сила:12, Ловкость:11, Телосложение:15, Мудрость:18, Харизма:20	Остроконечная булава, Роба болотного священника, Свиток круга бессмертия	t	50
4	6	Рагвалдур Балладный           	7	Аавил          	Бард                	Здоровье:112, Сила:16, Ловкость:17, Телосложение:13, Мудрость:15, Харизма:19	Тканые плащи дивного Траалла, Контрабас Бардской коллегии, Перо морской зари	f	48
5	3	Рунар Адрелик                 	5	Аавил          	Отшельник           	Здоровье:80, Сила:14, Ловкость:12, Телосложение:16, Мудрость:17, Харизма:14	Порванный плащ, Кинжал Тишины, Книга мудрости клана Кзерак	t	46
6	4	Олтер Мехо                    	9	Вуур           	Паладин             	Здоровье:150, Сила:22, Ловкость:13, Телосложение:21, Мудрость:16, Харизма:14	Священная броня Рассвета, Меч Правосудия, Щит Веры	t	55
7	5	Беззил Та-Зар                 	8	Кседокс        	Отшельник           	Здоровье:95, Сила:14, Ловкость:22, Телосложение:15, Мудрость:14, Харизма:18	Шелковистая тёмная роба, Прыткий кинжал, Кожаный мешочек	f	42
8	8	Каурок Диваг                  	8	Андеррекс      	Варвар              	Здоровье:138, Сила:20, Ловкость:13, Телосложение:19, Мудрость:10, Харизма:14	Кольчуга Боевого рёва, Двуручный топор "Кровавый гнев", Амулет Триумфа	f	42
9	9	Эделрик Песнопевец            	7	Аавил          	Бард                	Здоровье:114, Сила:15, Ловкость:16, Телосложение:12, Мудрость:16, Харизма:18	Плащ Подзабытых мелодий, Лютня Искры истоков, Бутыль мистического эха	f	48
10	2	Хагрим Неуступчивый           	5	Вуур           	Отшельник           	Здоровье:76, Сила:12, Ловкость:14, Телосложение:13, Мудрость:20, Харизма:17	Рваный плащ-палатка Пустоши, Палка-трость Зовущей темноты, Книга Забытых уроков	f	46
11	7	Фавандр Красносердечный       	6	Андеррекс      	Воин                	Здоровье:108, Сила:17, Ловкость:11, Телосложение:20, Мудрость:15, Харизма:13	Железный доспех Солнечной скалы, Боевой топор "Огненная мощь"	f	47
\.


--
-- Data for Name: npc_inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.npc_inventory (npc_inventory_id, npc_id, item_id, quantity) FROM stdin;
1	1	4	3
2	1	3	1
3	1	5	1
4	2	6	1
5	3	4	4
6	4	10	2
7	5	13	1
8	6	17	1
9	7	19	1
10	8	9	2
11	9	18	1
12	10	11	1
13	11	20	1
\.


--
-- Data for Name: npc_quests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.npc_quests (npc_quests_id, npc_id, quest_id) FROM stdin;
1	1	1
2	2	11
3	3	10
4	4	6
5	5	3
6	6	4
7	7	5
8	8	8
9	9	9
10	10	2
11	11	7
12	1	11
\.


--
-- Data for Name: player_character; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_character (pc_id, name, level, race, class, characteristics, equipment, unique_ability) FROM stdin;
1	FryerTucky                                             	3	Аавил          	Воин                	Здоровье:48, Сила:18, Ловкость:12, Телосложение:17, Мудрость:8, Харизма:12	\N	Грозовой рык                       
2	Адрик Шнейктик                                         	1	Вуур           	Воин                	Здоровье:30, Сила:13, Ловкость:10, Телосложение:12, Мудрость:8, Харизма:10	\N	Щит предков                        
3	Гаррок Разящий                                         	3	Андеррекс      	Варвар              	Здоровье:42, Сила:16, Ловкость:11, Телосложение:14, Мудрость:9, Харизма:8	\N	Ярость берсерка                    
4	Дариов Меткий глаз                                     	2	Аавил          	Воин                	Здоровье:35, Сила:14, Ловкость:12, Телосложение:10, Мудрость:11, Харизма:8	\N	Непоколебимый стой                 
5	Элтарон Звездный                                       	5	Вуур           	Жрец                	Здоровье:65, Сила:12, Ловкость:9, Телосложение:16, Мудрость:18, Харизма:14	\N	Исцеляющий свет                    
6	Ривел Кантрилт                                         	4	Кседокс        	Бард                	Здоровье:38, Сила:10, Ловкость:15, Телосложение:12, Мудрость:14, Харизма:17	\N	Гипнотическая мелодия              
7	Фендрик Ловец                                          	1	Андеррекс      	Отшельник           	Здоровье:30, Сила:12, Ловкость:10, Телосложение:13, Мудрость:15, Харизма:11	\N	Зов дикой природы                  
8	Лорден Гордый                                          	7	Аавил          	Паладин             	Здоровье:78, Сила:18, Ловкость:10, Телосложение:20, Мудрость:13, Харизма:16	\N	Молот света и правды               
9	Таргад Песноклин                                       	6	Вуур           	Воин                	Здоровье:84, Сила:15, Ловкость:13, Телосложение:16, Мудрость:11, Харизма:12	\N	Удар сумеречного воителя           
10	Эрнок Грязный Клык                                     	8	Кседокс        	Варвар              	Здоровье:97, Сила:20, Ловкость:9, Телосложение:18, Мудрость:7, Харизма:10	\N	Ярость болотных духов              
14	Игрок                                                  	1	раса           	Класс               	Здоровье:10, Сила:10, Ловкость:10, Телосложение:10, Мудрость:10, Харизма:11	\N	Уникальная способность             
15	Игрок                                                  	1	раса           	Класс               	Здоровье:10, Сила:10, Ловкость:10, Телосложение:10, Мудрость:10, Харизма:11	\N	Уникальная способность             
\.


--
-- Data for Name: player_inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_inventory (player_inventory_id, pc_id, item_id, quantity) FROM stdin;
1	1	34	1
2	2	34	1
3	3	33	1
4	4	34	1
5	5	34	1
6	6	34	1
7	7	34	1
8	8	34	1
9	9	34	1
10	10	36	1
11	1	8	1
12	6	26	1
\.


--
-- Data for Name: quests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quests (quest_id, location_id, name, description, task_type, difficulty_level, rewards) FROM stdin;
1	1	Выбраться из Альвадара                                      	Это ваше первое задание. Выберетесь из руин Альвадара вместе с Редриком Младшим, и заполучите первое необходимое снаряжение	Сюжетный                      	Лёгкий                        	100 золотых, Простая экипировка
2	2	Раскрытие Тайны Исчезновения Жителей                        	Проведите расследование и раскройте загадочное исчезновение жителей деревни.	Побочный                      	Средний                       	Звёздная мантия, 450 золотых
3	3	Исследование Подземных Катакомб                             	Вам предстоит погрузиться в темные подземные катакомбы замка и обнаружить их секреты.	Дополнительный                	Сложный                       	Пика Сияния, 250-500 золотых
4	4	Поиск Затерянного Храма                                     	Исследуйте тёмный лес, чтобы отыскать древний храм, погружённый в таинственную атмосферу.	Сюжетный                      	Средний                       	Амулет Вечности, 400 золотых
5	5	Разгадка Загадки Пропавшего Груза                           	Путешествуйте по подземным городам Железного Рудника и разгадайте тайну пропавшего груза.	Дополнительный                	Сложный                       	Молот Справедливости, 600 золотых
6	6	Тайны Таинственного Храма                                   	Изучите равнины Искусителей и раскройте тайны древнего храма, погружённого в зловещую тайну.	Сюжетный                      	Сложный                       	Кристалл Хранителя, 800 золотых
7	7	Поиски Пропавшего Магистра                                  	Проследуйте по улицам и скрытым уголкам Города Серебряных Башен, чтобы найти следы пропавшего магистра.	Сюжетный                      	Лёгкий                        	Посох Владыки элементов, 450 золотых
8	8	Защита Каменной Крепости                                    	Помогите оборонить Каменные Крепости Каргимар от нападения отступников и спасите славное прошлое крепости.	Сюжетный                      	Сложный                       	Громовой Меч, 700 золотых
9	9	Разгадка Проклятия Забытых Снов                             	Погрузитесь в тайны и загадки Деревни Забытых Снов, чтобы раскрыть проклятие, обволакивающее поселение.	Побочный                      	Средний                       	Амулет Безмятежности, 850 золотых
10	10	Поиск Артефакта Забытых Королей                             	Смело спускайтесь в Глубины Чёрного Ключа, чтобы добыть древний артефакт, утерянный в веках.	Сюжетный                      	Средний                       	Меч Тёмных вибраций, 750 золотых
11	11	Спасение из Тёмной Пещеры Ноктал                            	Проникните в Тёмную Пещеру Ноктал, чтобы спасти пленников и одержать победу над хищником-главарём.	Сюжетный                      	Сложный                       	Щит Теней, 900 золотых
\.


--
-- Data for Name: time_of_creation_new_pc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.time_of_creation_new_pc (pc_id, login_time) FROM stdin;
12	2024-06-13 22:10:51.104613
13	2024-06-13 22:15:18.317237
14	2024-06-14 18:23:00.311031
15	2024-06-14 19:34:08.122637
\.


--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.achievements_achievement_id_seq', 11, true);


--
-- Name: achievements_quest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.achievements_quest_id_seq', 1, false);


--
-- Name: game_items_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.game_items_item_id_seq', 46, true);


--
-- Name: locations_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_location_id_seq', 11, true);


--
-- Name: npc_inventory_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_inventory_item_id_seq', 1, false);


--
-- Name: npc_inventory_npc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_inventory_npc_id_seq', 1, false);


--
-- Name: npc_inventory_npc_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_inventory_npc_inventory_id_seq', 13, true);


--
-- Name: npc_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_location_id_seq', 1, false);


--
-- Name: npc_npc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_npc_id_seq', 11, true);


--
-- Name: npc_quests_npc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_quests_npc_id_seq', 1, false);


--
-- Name: npc_quests_npc_quests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_quests_npc_quests_id_seq', 12, true);


--
-- Name: npc_quests_quest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npc_quests_quest_id_seq', 1, false);


--
-- Name: player_character_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_character_pc_id_seq', 15, true);


--
-- Name: player_inventory_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_inventory_item_id_seq', 1, false);


--
-- Name: player_inventory_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_inventory_pc_id_seq', 1, false);


--
-- Name: player_inventory_player_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_inventory_player_inventory_id_seq', 12, true);


--
-- Name: player_progress_achievement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_progress_achievement_id_seq', 1, true);


--
-- Name: player_progress_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_progress_location_id_seq', 1, true);


--
-- Name: player_progress_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_progress_pc_id_seq', 1, false);


--
-- Name: player_progress_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_progress_progress_id_seq', 11, true);


--
-- Name: player_progress_quest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_progress_quest_id_seq', 1, true);


--
-- Name: quests_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quests_location_id_seq', 1, false);


--
-- Name: quests_player_characters_pc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quests_player_characters_pc_id_seq', 1, false);


--
-- Name: quests_player_characters_quest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quests_player_characters_quest_id_seq', 1, false);


--
-- Name: quests_player_characters_quests_player_ch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quests_player_characters_quests_player_ch_id_seq', 13, true);


--
-- Name: quests_quest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quests_quest_id_seq', 11, true);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (achievement_id);


--
-- Name: game_items game_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_items
    ADD CONSTRAINT game_items_pkey PRIMARY KEY (item_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);


--
-- Name: npc_inventory npc_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory
    ADD CONSTRAINT npc_inventory_pkey PRIMARY KEY (npc_inventory_id);


--
-- Name: npc npc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc
    ADD CONSTRAINT npc_pkey PRIMARY KEY (npc_id);


--
-- Name: npc_quests npc_quests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests
    ADD CONSTRAINT npc_quests_pkey PRIMARY KEY (npc_quests_id);


--
-- Name: player_character player_character_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_character
    ADD CONSTRAINT player_character_pkey PRIMARY KEY (pc_id);


--
-- Name: player_inventory player_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory
    ADD CONSTRAINT player_inventory_pkey PRIMARY KEY (player_inventory_id);


--
-- Name: current_game_statistics player_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics
    ADD CONSTRAINT player_progress_pkey PRIMARY KEY (progress_id);


--
-- Name: quests quests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_pkey PRIMARY KEY (quest_id);


--
-- Name: current_quests quests_player_characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests
    ADD CONSTRAINT quests_player_characters_pkey PRIMARY KEY (current_quests_id);


--
-- Name: game_items log_deleted_data_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_deleted_data_trigger AFTER DELETE ON public.game_items FOR EACH ROW EXECUTE FUNCTION public.log_deleted_data();


--
-- Name: player_character player_login_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER player_login_trigger BEFORE INSERT ON public.player_character FOR EACH ROW EXECUTE FUNCTION public.log_player_login_time();


--
-- Name: achievements achievements_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(quest_id);


--
-- Name: npc_inventory npc_inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory
    ADD CONSTRAINT npc_inventory_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.game_items(item_id);


--
-- Name: npc_inventory npc_inventory_npc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_inventory
    ADD CONSTRAINT npc_inventory_npc_id_fkey FOREIGN KEY (npc_id) REFERENCES public.npc(npc_id);


--
-- Name: npc npc_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc
    ADD CONSTRAINT npc_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: npc_quests npc_quests_npc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests
    ADD CONSTRAINT npc_quests_npc_id_fkey FOREIGN KEY (npc_id) REFERENCES public.npc(npc_id);


--
-- Name: npc_quests npc_quests_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npc_quests
    ADD CONSTRAINT npc_quests_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(quest_id);


--
-- Name: player_inventory player_inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory
    ADD CONSTRAINT player_inventory_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.game_items(item_id);


--
-- Name: player_inventory player_inventory_pc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_inventory
    ADD CONSTRAINT player_inventory_pc_id_fkey FOREIGN KEY (pc_id) REFERENCES public.player_character(pc_id);


--
-- Name: current_game_statistics player_progress_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics
    ADD CONSTRAINT player_progress_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(achievement_id);


--
-- Name: current_game_statistics player_progress_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics
    ADD CONSTRAINT player_progress_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: current_game_statistics player_progress_pc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics
    ADD CONSTRAINT player_progress_pc_id_fkey FOREIGN KEY (pc_id) REFERENCES public.player_character(pc_id);


--
-- Name: current_game_statistics player_progress_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_game_statistics
    ADD CONSTRAINT player_progress_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(quest_id);


--
-- Name: quests quests_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: current_quests quests_player_characters_pc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests
    ADD CONSTRAINT quests_player_characters_pc_id_fkey FOREIGN KEY (pc_id) REFERENCES public.player_character(pc_id);


--
-- Name: current_quests quests_player_characters_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_quests
    ADD CONSTRAINT quests_player_characters_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(quest_id);


--
-- PostgreSQL database dump complete
--

