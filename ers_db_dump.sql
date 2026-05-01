--
-- PostgreSQL database dump
--

\restrict uI1oaOjBZClbvE0p7cfIPnIzN6XQKapQ6QwDj8u6vigCE1JL8OT1ZOrjOdtGpCK

-- Dumped from database version 18.3 (Postgres.app)
-- Dumped by pg_dump version 18.3 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ers_component_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ers_component_scores (
    score_id character varying(36) NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id character varying(300) NOT NULL,
    component character varying(20) NOT NULL,
    window_days integer NOT NULL,
    window_end date NOT NULL,
    raw_score double precision,
    normalised_score double precision,
    signal_count integer,
    top_signals text,
    computed_at timestamp with time zone
);


ALTER TABLE public.ers_component_scores OWNER TO postgres;

--
-- Name: ers_composite_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ers_composite_scores (
    composite_id character varying(36) NOT NULL,
    entity_type character varying(20) NOT NULL,
    entity_id character varying(300) NOT NULL,
    window_days integer NOT NULL,
    window_end date NOT NULL,
    ers_score double precision NOT NULL,
    ers_band character varying(20),
    regulatory_score double precision,
    legislative_score double precision,
    political_score double precision,
    judicial_score double precision,
    media_score double precision,
    complaint_score double precision,
    w_regulatory double precision,
    w_legislative double precision,
    w_political double precision,
    w_judicial double precision,
    w_media double precision,
    w_complaint double precision,
    weight_version character varying(50),
    data_completeness double precision,
    computed_at timestamp with time zone
);


ALTER TABLE public.ers_composite_scores OWNER TO postgres;

--
-- Name: i1_volume_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.i1_volume_statistics (
    stat_id character varying(36) NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    period_type character varying(20) NOT NULL,
    ico_sector character varying(200) NOT NULL,
    sector_relevance character varying(10) NOT NULL,
    complaint_count integer NOT NULL,
    data_breach_count integer,
    complaint_resolved boolean,
    complaint_resolved_pct double precision,
    yoy_change_pct double precision,
    qoq_change_pct double precision,
    avg_3period double precision,
    pct_above_avg double precision,
    spike_flag boolean,
    source_doc text,
    source_url text,
    ingested_at timestamp with time zone,
    manually_reviewed boolean,
    pct_resolved real,
    CONSTRAINT ck_i1_complaint_count CHECK ((complaint_count >= 0)),
    CONSTRAINT ck_i1_period_dates CHECK ((period_end > period_start)),
    CONSTRAINT ck_i1_period_type CHECK (((period_type)::text = ANY ((ARRAY['Annual'::character varying, 'Quarterly'::character varying, 'FOI Response'::character varying])::text[]))),
    CONSTRAINT ck_i1_sector_relevance CHECK (((sector_relevance)::text = ANY ((ARRAY['Full'::character varying, 'Partial'::character varying, 'None'::character varying])::text[])))
);


ALTER TABLE public.i1_volume_statistics OWNER TO postgres;

--
-- Name: i2_volume_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.i2_volume_scores (
    score_id character varying(36) NOT NULL,
    ico_sector character varying(200) NOT NULL,
    ref_period_start date NOT NULL,
    ref_period_end date NOT NULL,
    complaint_count_used integer NOT NULL,
    avg_3period_used double precision NOT NULL,
    volume_factor double precision,
    trend_direction character varying(10),
    spike_active boolean,
    sector_risk_modifier double precision,
    data_lag integer,
    stale_flag boolean,
    computed_at timestamp with time zone,
    CONSTRAINT ck_i2_data_lag CHECK ((data_lag >= 0)),
    CONSTRAINT ck_i2_trend_direction CHECK (((trend_direction)::text = ANY ((ARRAY['Rising'::character varying, 'Stable'::character varying, 'Falling'::character varying])::text[]))),
    CONSTRAINT ck_i2_volume_factor CHECK ((volume_factor >= (0)::double precision))
);


ALTER TABLE public.i2_volume_scores OWNER TO postgres;

--
-- Name: j1_supreme_court; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.j1_supreme_court (
    supreme_id character varying(36) NOT NULL,
    case_name character varying(500) NOT NULL,
    neutral_citation character varying(100),
    decision_date date NOT NULL,
    subject_matter character varying(200),
    appellant character varying(300),
    respondent character varying(300),
    appellant_type character varying(50),
    respondent_type character varying(50),
    ico_role character varying(30),
    ico_position_upheld boolean,
    outcome_direction character varying(20),
    outcome_summary text,
    precedent_weight character varying(30) NOT NULL,
    processing_activities character varying(500),
    gdpr_articles character varying(500),
    gdpr_principles character varying(500),
    damages_awarded boolean,
    damages_amount numeric(15,2),
    ai_specific boolean,
    widens_controller_liability boolean,
    restricts_ico_powers boolean,
    enforcement_signal double precision,
    case_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    restrict_ico_powers boolean,
    CONSTRAINT ck_j1_appellant_type CHECK (((appellant_type)::text = ANY ((ARRAY['Data Subject'::character varying, 'Controller'::character varying, 'Processor'::character varying, 'Regulator'::character varying, 'Government'::character varying])::text[]))),
    CONSTRAINT ck_j1_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_j1_ico_role CHECK (((ico_role)::text = ANY ((ARRAY['Party (Appellant)'::character varying, 'Party (Respondent)'::character varying, 'Intervener'::character varying, 'Amicus'::character varying, 'None'::character varying])::text[]))),
    CONSTRAINT ck_j1_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_j1_outcome_direction CHECK (((outcome_direction)::text = ANY ((ARRAY['Controller'::character varying, 'Data Subject'::character varying, 'ICO'::character varying, 'Mixed'::character varying, 'Procedural'::character varying])::text[]))),
    CONSTRAINT ck_j1_precedent_weight CHECK (((precedent_weight)::text = ANY ((ARRAY['Binding'::character varying, 'Highly Persuasive'::character varying, 'Persuasive'::character varying])::text[]))),
    CONSTRAINT ck_j1_respondent_type CHECK (((respondent_type)::text = ANY ((ARRAY['Data Subject'::character varying, 'Controller'::character varying, 'Processor'::character varying, 'Regulator'::character varying, 'Government'::character varying])::text[])))
);


ALTER TABLE public.j1_supreme_court OWNER TO postgres;

--
-- Name: j2_court_of_appeal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.j2_court_of_appeal (
    appeal_id character varying(36) NOT NULL,
    case_name character varying(500) NOT NULL,
    neutral_citation character varying(100),
    decision_date date NOT NULL,
    division character varying(20) NOT NULL,
    subject_matter character varying(200),
    appellant_type character varying(50),
    respondent_type character varying(50),
    ico_role character varying(30),
    ico_position_upheld boolean,
    outcome_direction character varying(20),
    outcome_summary text,
    precedent_weight character varying(30) NOT NULL,
    processing_activities character varying(500),
    gdpr_articles character varying(500),
    gdpr_principles character varying(500),
    damages_awarded boolean,
    damages_amount numeric(15,2),
    ai_specific boolean,
    widens_controller_liability boolean,
    restricts_ico_powers boolean,
    enforcement_signal double precision,
    case_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    restrict_ico_powers boolean,
    CONSTRAINT ck_j2_appellant_type CHECK (((appellant_type)::text = ANY ((ARRAY['Data Subject'::character varying, 'Controller'::character varying, 'Processor'::character varying, 'Regulator'::character varying, 'Government'::character varying])::text[]))),
    CONSTRAINT ck_j2_division CHECK (((division)::text = ANY ((ARRAY['Civil'::character varying, 'Criminal'::character varying])::text[]))),
    CONSTRAINT ck_j2_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_j2_ico_role CHECK (((ico_role)::text = ANY ((ARRAY['Party (Appellant)'::character varying, 'Party (Respondent)'::character varying, 'Intervener'::character varying, 'Amicus'::character varying, 'None'::character varying])::text[]))),
    CONSTRAINT ck_j2_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_j2_outcome_direction CHECK (((outcome_direction)::text = ANY ((ARRAY['Controller'::character varying, 'Data Subject'::character varying, 'ICO'::character varying, 'Mixed'::character varying, 'Procedural'::character varying])::text[]))),
    CONSTRAINT ck_j2_precedent_weight CHECK (((precedent_weight)::text = ANY ((ARRAY['Binding'::character varying, 'Highly Persuasive'::character varying, 'Persuasive'::character varying])::text[]))),
    CONSTRAINT ck_j2_respondent_type CHECK (((respondent_type)::text = ANY ((ARRAY['Data Subject'::character varying, 'Controller'::character varying, 'Processor'::character varying, 'Regulator'::character varying, 'Government'::character varying])::text[])))
);


ALTER TABLE public.j2_court_of_appeal OWNER TO postgres;

--
-- Name: j3_information_rights_tribunal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.j3_information_rights_tribunal (
    tribunal_id character varying(36) NOT NULL,
    case_reference character varying(100) NOT NULL,
    tier character varying(50) NOT NULL,
    decision_date date NOT NULL,
    case_type character varying(50) NOT NULL,
    appellant_type character varying(50),
    ico_role character varying(20),
    ico_position_upheld boolean,
    outcome_direction character varying(20),
    original_penalty_gbp numeric(25,2),
    revised_penalty_gbp numeric(25,2),
    penalty_reduction_pct double precision,
    appeals_ground character varying(500),
    processing_activities character varying(500),
    gdpr_articles character varying(500),
    ai_specific boolean,
    precedent_weight character varying(30),
    enforcement_signal double precision,
    case_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_j3_appellant_type CHECK (((appellant_type)::text = ANY ((ARRAY['Controller'::character varying, 'Processor'::character varying, 'Data Subject'::character varying, 'ICO'::character varying])::text[]))),
    CONSTRAINT ck_j3_case_type CHECK (((case_type)::text = ANY ((ARRAY['Enforcement Notice Appeal'::character varying, 'Monetary Penalty Appeal'::character varying, 'Information Notice Appeal'::character varying, 'Data Subject Rights Appeal'::character varying])::text[]))),
    CONSTRAINT ck_j3_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_j3_ico_role CHECK (((ico_role)::text = ANY ((ARRAY['Respondent'::character varying, 'Appellant'::character varying, 'None'::character varying])::text[]))),
    CONSTRAINT ck_j3_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_j3_outcome_direction CHECK (((outcome_direction)::text = ANY ((ARRAY['Controller'::character varying, 'Data Subject'::character varying, 'ICO'::character varying, 'Mixed'::character varying, 'Procedural'::character varying])::text[]))),
    CONSTRAINT ck_j3_precedent_weight CHECK (((precedent_weight)::text = ANY ((ARRAY['Binding'::character varying, 'Highly Persuasive'::character varying, 'Persuasive'::character varying])::text[]))),
    CONSTRAINT ck_j3_tier CHECK (((tier)::text = ANY (ARRAY[('First-tier'::character varying)::text, ('Upper Tribunal'::character varying)::text])))
);


ALTER TABLE public.j3_information_rights_tribunal OWNER TO postgres;

--
-- Name: j4_high_court; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.j4_high_court (
    highcourt_id character varying(36) NOT NULL,
    case_name character varying(500) NOT NULL,
    neutral_citation character varying(100),
    decision_date date NOT NULL,
    division character varying(30) NOT NULL,
    case_type character varying(50) NOT NULL,
    ico_role character varying(20),
    ico_position_upheld boolean,
    jr_permission_granted boolean,
    outcome_direction character varying(20),
    outcome_summary text,
    precedent_weight character varying(30) NOT NULL,
    processing_activities character varying(500),
    gdpr_articles character varying(500),
    gdpr_principles character varying(500),
    damages_awarded boolean,
    damages_amount numeric(15,2),
    ai_specific boolean,
    widens_controller_liability boolean,
    restricts_ico_powers boolean,
    enforcement_signal double precision,
    case_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    restrict_ico_powers boolean,
    CONSTRAINT ck_j4_case_type CHECK (((case_type)::text = ANY ((ARRAY['Judicial Review'::character varying, 'Civil Damages Claim'::character varying, 'Injunction'::character varying, 'Declaration'::character varying])::text[]))),
    CONSTRAINT ck_j4_division CHECK (((division)::text = ANY ((ARRAY['King''s Bench'::character varying, 'Chancery'::character varying, 'Family'::character varying])::text[]))),
    CONSTRAINT ck_j4_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_j4_ico_role CHECK (((ico_role)::text = ANY ((ARRAY['Party (Appellant)'::character varying, 'Party (Respondent)'::character varying, 'Intervener'::character varying, 'Amicus'::character varying, 'Defendant'::character varying, 'None'::character varying])::text[]))),
    CONSTRAINT ck_j4_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_j4_outcome_direction CHECK (((outcome_direction)::text = ANY ((ARRAY['Controller'::character varying, 'Data Subject'::character varying, 'ICO'::character varying, 'Mixed'::character varying, 'Procedural'::character varying])::text[]))),
    CONSTRAINT ck_j4_precedent_weight CHECK (((precedent_weight)::text = ANY ((ARRAY['Binding'::character varying, 'Highly Persuasive'::character varying, 'Persuasive'::character varying])::text[])))
);


ALTER TABLE public.j4_high_court OWNER TO postgres;

--
-- Name: l1_bills_in_parliament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.l1_bills_in_parliament (
    bill_id character varying(36) NOT NULL,
    parliament_bill_id character varying(50) NOT NULL,
    bill_type character varying(50) NOT NULL,
    bill_title character varying(500) NOT NULL,
    session character varying(20) NOT NULL,
    event_type character varying(100) NOT NULL,
    event_date date NOT NULL,
    house character varying(10) NOT NULL,
    bill_stage_numeric integer NOT NULL,
    bill_status character varying(20) NOT NULL,
    expected_commencement date,
    processing_activities character varying(500),
    relevance_score double precision,
    relevance_tag character varying(500),
    nlp_confidence double precision,
    obligation_direction character varying(20),
    affects_ico boolean,
    source_url text,
    rss_guid character varying(500),
    ingested_at timestamp with time zone,
    manually_reviewed boolean,
    CONSTRAINT ck_l1_bill_status CHECK (((bill_status)::text = ANY ((ARRAY['Active'::character varying, 'Passed'::character varying, 'Withdrawn'::character varying, 'Lapsed'::character varying])::text[]))),
    CONSTRAINT ck_l1_bill_type CHECK (((bill_type)::text = ANY ((ARRAY['Government'::character varying, 'Private Members'::character varying, 'Hybrid'::character varying, 'Private'::character varying])::text[]))),
    CONSTRAINT ck_l1_event_type CHECK (((event_type)::text = ANY ((ARRAY['Introduced'::character varying, 'First Reading'::character varying, 'Second Reading'::character varying, 'Committee Stage'::character varying, 'Report Stage'::character varying, 'Third Reading'::character varying, 'Lords Introduction'::character varying, 'Lords Amendments'::character varying, 'Ping Pong'::character varying, 'Royal Assent'::character varying, 'Withdrawal'::character varying, 'Lapse'::character varying])::text[]))),
    CONSTRAINT ck_l1_house CHECK (((house)::text = ANY ((ARRAY['Commons'::character varying, 'Lords'::character varying, 'Both'::character varying])::text[]))),
    CONSTRAINT ck_l1_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_l1_obligation_direction CHECK (((obligation_direction)::text = ANY ((ARRAY['Increases'::character varying, 'Decreases'::character varying, 'Clarifies'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_l1_relevance_score CHECK (((relevance_score >= (0)::double precision) AND (relevance_score <= (1)::double precision)))
);


ALTER TABLE public.l1_bills_in_parliament OWNER TO postgres;

--
-- Name: l2_statutory_instruments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.l2_statutory_instruments (
    si_id character varying(36) NOT NULL,
    si_number character varying(50) NOT NULL,
    si_title character varying(500) NOT NULL,
    si_type character varying(100) NOT NULL,
    parent_act_id character varying(36),
    parent_act_name character varying(500),
    made_date date,
    laid_date date,
    force_date date,
    provisions_commenced text,
    si_status character varying(20),
    processing_activities character varying(500),
    relevance_score double precision,
    relevance_tag character varying(500),
    nlp_confidence double precision,
    obligation_type character varying(100),
    affects_ico boolean,
    source_url text,
    rss_guid character varying(500),
    ingested_at timestamp with time zone,
    manually_reviewed boolean,
    days_to_force integer,
    CONSTRAINT ck_l2_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_l2_relevance_score CHECK (((relevance_score >= (0)::double precision) AND (relevance_score <= (1)::double precision))),
    CONSTRAINT ck_l2_si_status CHECK (((si_status)::text = ANY ((ARRAY['Made'::character varying, 'In Force'::character varying, 'Revoked'::character varying, 'Amended'::character varying])::text[]))),
    CONSTRAINT ck_l2_si_type CHECK (((si_type)::text = ANY ((ARRAY['Commencement Order'::character varying, 'Amendment SI'::character varying, 'Regulatory Reform Order'::character varying, 'Other'::character varying])::text[])))
);


ALTER TABLE public.l2_statutory_instruments OWNER TO postgres;

--
-- Name: m1_ngo_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.m1_ngo_activity (
    ngo_activity_id character varying(36) NOT NULL,
    ngo_name character varying(200) NOT NULL,
    publication_date date NOT NULL,
    activity_type character varying(50) NOT NULL,
    title text NOT NULL,
    source_url text,
    target_org character varying(300),
    ico_named boolean,
    formal_complaint boolean,
    complaint_ref character varying(100),
    legal_action boolean,
    content_summary text,
    processing_activities character varying(500),
    topic_relevance_score double precision,
    enforcement_stance character varying(20),
    gdpr_articles character varying(500),
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    ngo_id character varying(200),
    activity_date character varying(200),
    organisation character varying(200),
    org_type character varying(200),
    summary character varying(512),
    topic_tags character varying(200),
    target_organisation character varying(200),
    target_type character varying(200),
    ico_complaint_raised boolean,
    outcome character varying(200),
    enforcement_signal real,
    CONSTRAINT ck_m1_activity_type CHECK (((activity_type)::text = ANY ((ARRAY['Publication'::character varying, 'Press Release'::character varying, 'Formal Complaint'::character varying, 'Legal Challenge'::character varying, 'Parliamentary Submission'::character varying, 'Open Letter'::character varying, 'Report'::character varying])::text[]))),
    CONSTRAINT ck_m1_enforcement_stance CHECK (((enforcement_stance)::text = ANY ((ARRAY['Pro-enforcement'::character varying, 'Neutral'::character varying, 'Deregulatory'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_m1_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_m1_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.m1_ngo_activity OWNER TO postgres;

--
-- Name: m2_media_press; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.m2_media_press (
    press_id character varying(36) NOT NULL,
    publication_date date NOT NULL,
    outlet character varying(100) NOT NULL,
    outlet_tier integer NOT NULL,
    headline text NOT NULL,
    source_url text,
    author text,
    story_type character varying(50) NOT NULL,
    target_org character varying(300),
    ico_mentioned boolean,
    ico_action boolean,
    content_summary text,
    processing_activities character varying(500),
    topic_relevance_score double precision,
    enforcement_stance character varying(20),
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_m2_enforcement_stance CHECK (((enforcement_stance)::text = ANY ((ARRAY['Pro-enforcement'::character varying, 'Neutral'::character varying, 'Pro-regulatory'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_m2_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_m2_outlet_tier CHECK ((outlet_tier = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_m2_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision))),
    CONSTRAINT ck_m2_story_type CHECK (((story_type)::text = ANY ((ARRAY['Investigation'::character varying, 'Opinion'::character varying, 'News'::character varying, 'Data Breach'::character varying, 'Regulatory Response'::character varying, 'Profile'::character varying])::text[])))
);


ALTER TABLE public.m2_media_press OWNER TO postgres;

--
-- Name: p1_government_speeches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p1_government_speeches (
    speech_id character varying(36) NOT NULL,
    title character varying(500) NOT NULL,
    speaker_name character varying(200),
    speaker_role character varying(300),
    party character varying(100),
    department character varying(100) NOT NULL,
    speech_date date NOT NULL,
    speech_url text,
    rss_guid character varying(500),
    topic_relevance_score double precision,
    processing_activities character varying(500),
    relevance_tag character varying(500),
    priority_level character varying(20),
    regulatory_stance character varying(20),
    enforcement_signal double precision,
    nlp_confidence double precision,
    ico_mentioned boolean,
    ingested_at timestamp with time zone,
    raw_text text,
    manually_reviewed boolean,
    topic_relevence_score real,
    CONSTRAINT ck_p1_department CHECK (((department)::text = ANY ((ARRAY['DSIT'::character varying, 'Cabinet Office'::character varying, 'Home Office'::character varying, 'HM Treasury'::character varying, 'DCMS'::character varying, 'MOJ'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_p1_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_p1_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_p1_priority_level CHECK (((priority_level)::text = ANY ((ARRAY['Primary'::character varying, 'Secondary'::character varying, 'Peripheral'::character varying, 'None'::character varying])::text[]))),
    CONSTRAINT ck_p1_regulatory_stance CHECK (((regulatory_stance)::text = ANY ((ARRAY['Pro-enforcement'::character varying, 'Neutral'::character varying, 'Deregulatory'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_p1_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.p1_government_speeches OWNER TO postgres;

--
-- Name: p2_party_manifestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p2_party_manifestos (
    manifesto_id character varying(36) NOT NULL,
    party character varying(100) NOT NULL,
    election_year integer NOT NULL,
    commitment_text text NOT NULL,
    processing_activities character varying(500),
    topic_tags character varying(500),
    obligation_direction character varying(20),
    priority_level character varying(20),
    governing_party boolean,
    manifesto_project_id character varying(100),
    source_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_p2_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_p2_obligation_direction CHECK (((obligation_direction)::text = ANY ((ARRAY['Increases'::character varying, 'Decreases'::character varying, 'Clarifies'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_p2_priority_level CHECK (((priority_level)::text = ANY ((ARRAY['Primary'::character varying, 'Secondary'::character varying, 'Peripheral'::character varying])::text[])))
);


ALTER TABLE public.p2_party_manifestos OWNER TO postgres;

--
-- Name: p3_budget_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p3_budget_documents (
    budget_id character varying(36) NOT NULL,
    budget_year integer NOT NULL,
    budget_date date NOT NULL,
    item_type character varying(100) NOT NULL,
    item_description text NOT NULL,
    amount_gbp numeric(15,2),
    yoy_change_pct double precision,
    yoy_direction character varying(20),
    ico_budget_flag boolean,
    enforcement_signal double precision,
    source_url text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_p3_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_p3_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_p3_yoy_direction CHECK (((yoy_direction)::text = ANY ((ARRAY['Increase'::character varying, 'Decrease'::character varying, 'Flat'::character varying, 'New Item'::character varying])::text[])))
);


ALTER TABLE public.p3_budget_documents OWNER TO postgres;

--
-- Name: p4_electoral_signals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p4_electoral_signals (
    electoral_id character varying(36) NOT NULL,
    record_date date NOT NULL,
    last_election_date date NOT NULL,
    next_election_due date NOT NULL,
    governing_party character varying(100) NOT NULL,
    governing_poll_ptc double precision,
    opposition_poll_ptc double precision,
    poll_source character varying(200),
    prediction_market_prob double precision,
    gov_change_12m double precision,
    ingested_at timestamp with time zone,
    labour_poll_ptc real,
    conservative_poll_ptc real,
    libdem_poll_ptc real,
    reform_poll_ptc real,
    green_poll_ptc real,
    CONSTRAINT ck_p4_gov_change_12m CHECK (((gov_change_12m >= (0)::double precision) AND (gov_change_12m <= (1)::double precision))),
    CONSTRAINT ck_p4_governing_poll_ptc CHECK (((governing_poll_ptc >= (0)::double precision) AND (governing_poll_ptc <= (100)::double precision))),
    CONSTRAINT ck_p4_opposition_poll_ptc CHECK (((opposition_poll_ptc >= (0)::double precision) AND (opposition_poll_ptc <= (100)::double precision))),
    CONSTRAINT ck_p4_prediction_market_prob CHECK (((prediction_market_prob >= (0)::double precision) AND (prediction_market_prob <= (1)::double precision)))
);


ALTER TABLE public.p4_electoral_signals OWNER TO postgres;

--
-- Name: p5_social_listening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p5_social_listening (
    social_id character varying(36) NOT NULL,
    platform character varying(50) NOT NULL,
    account_handle character varying(200) NOT NULL,
    account_name character varying(200),
    account_category character varying(50) NOT NULL,
    party character varying(100),
    party_power boolean,
    post_date timestamp with time zone NOT NULL,
    post_id_platform character varying(200),
    raw_text text,
    processing_activities character varying(500),
    topic_relevance_score double precision,
    topic_tags character varying(500),
    priority_level character varying(20),
    regulatory_stance character varying(20),
    engagement_score integer,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    topic_relevence_score real,
    CONSTRAINT ck_p5_account_category CHECK (((account_category)::text = ANY ((ARRAY['Regulator'::character varying, 'Minister'::character varying, 'Shadow Minister'::character varying, 'Party Leader'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_p5_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_p5_priority_level CHECK (((priority_level)::text = ANY ((ARRAY['Primary'::character varying, 'Secondary'::character varying, 'Peripheral'::character varying])::text[]))),
    CONSTRAINT ck_p5_regulatory_stance CHECK (((regulatory_stance)::text = ANY ((ARRAY['Pro-enforcement'::character varying, 'Neutral'::character varying, 'Deregulatory'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_p5_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.p5_social_listening OWNER TO postgres;

--
-- Name: p6_parliamentary_qa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.p6_parliamentary_qa (
    pqa_id character varying(36) NOT NULL,
    question_date date NOT NULL,
    answer_date date,
    question_type character varying(20) NOT NULL,
    asking_mp character varying(200) NOT NULL,
    asking_party character varying(100),
    asking_party_gov boolean,
    answering_minister character varying(200),
    answering_department character varying(200),
    answering_party character varying(100),
    question_text text NOT NULL,
    answer_text text,
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    priority_level character varying(20),
    government_position character varying(50),
    ico_mentioned boolean,
    enforcement_signal double precision,
    source_url text,
    rss_guid character varying(500),
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_p6_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_p6_government_position CHECK (((government_position)::text = ANY ((ARRAY['Supportive of Enforcement'::character varying, 'Neutral'::character varying, 'Resistant'::character varying, 'Unclear'::character varying])::text[]))),
    CONSTRAINT ck_p6_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_p6_priority_level CHECK (((priority_level)::text = ANY ((ARRAY['Primary'::character varying, 'Secondary'::character varying, 'Peripheral'::character varying])::text[]))),
    CONSTRAINT ck_p6_question_type CHECK (((question_type)::text = ANY ((ARRAY['Written'::character varying, 'Oral'::character varying, 'Urgent'::character varying])::text[]))),
    CONSTRAINT ck_p6_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.p6_parliamentary_qa OWNER TO postgres;

--
-- Name: r1_enforcement_register; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r1_enforcement_register (
    enforcement_id character varying(36) NOT NULL,
    ico_reference character varying(100),
    org_name character varying(500) NOT NULL,
    org_type character varying(100) NOT NULL,
    org_size character varying(30),
    action_date date NOT NULL,
    action_type character varying(100) NOT NULL,
    outcome character varying(30),
    penalty_gbp numeric(15,2),
    penalty_as_max double precision,
    severity_tier character varying(20),
    aggravating_factors character varying(500),
    mitigating_factors character varying(500),
    appealed boolean,
    appeal_outcome character varying(200),
    processing_activities character varying(500),
    legislation_breached character varying(500),
    gdpr_principles character varying(500),
    special_category_data boolean,
    cross_border boolean,
    ai_specific boolean,
    prior_ico_contact boolean,
    prior_contact_types character varying(500),
    prior_contact_count integer,
    days_prior_contact integer,
    org_type_recidivism_rate double precision,
    enforcement_signal double precision,
    nlp_confidence double precision,
    source_url text,
    raw_summary text,
    ingested_at timestamp with time zone,
    manually_reviewed boolean,
    regulatory_regime character varying(200),
    CONSTRAINT ck_r1_action_type CHECK (((action_type)::text = ANY ((ARRAY['Monetary Penalty Notice'::character varying, 'Enforcement Notice'::character varying, 'Information Notice'::character varying, 'Assessment Notice'::character varying, 'Undertaking'::character varying, 'Reprimand'::character varying, 'Warning'::character varying, 'Prosecution'::character varying, 'Stop Processing Order'::character varying, 'Advisory Visit'::character varying])::text[]))),
    CONSTRAINT ck_r1_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r1_outcome CHECK (((outcome)::text = ANY ((ARRAY['Upheld'::character varying, 'Settled'::character varying, 'Overturned on Appeal'::character varying, 'Under Appeal'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_r1_penalty_as_max CHECK (((penalty_as_max >= (0)::double precision) AND (penalty_as_max <= (1)::double precision))),
    CONSTRAINT ck_r1_severity_tier CHECK (((severity_tier)::text = ANY ((ARRAY['Critical'::character varying, 'High'::character varying, 'Medium'::character varying, 'Low'::character varying, 'Advisory'::character varying])::text[])))
);


ALTER TABLE public.r1_enforcement_register OWNER TO postgres;

--
-- Name: r2_ico_news; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r2_ico_news (
    news_id character varying(36) NOT NULL,
    title character varying(500) NOT NULL,
    publication_date date NOT NULL,
    content_type character varying(50) NOT NULL,
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    signal_investigation boolean,
    signal_consultation boolean,
    enforcement_signal double precision,
    source_url text,
    rss_guid character varying(500),
    raw_text text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_r2_content_type CHECK (((content_type)::text = ANY ((ARRAY['News'::character varying, 'Blog'::character varying, 'Press Release'::character varying, 'Statement'::character varying, 'Investigation Announcement'::character varying])::text[]))),
    CONSTRAINT ck_r2_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_r2_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r2_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.r2_ico_news OWNER TO postgres;

--
-- Name: r3_ico_consultations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r3_ico_consultations (
    consultation_id character varying(36) NOT NULL,
    title character varying(500) NOT NULL,
    publication_date date NOT NULL,
    document_type character varying(50) NOT NULL,
    consultation_status character varying(30),
    consultation_closes date,
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    obligation_direction character varying(20),
    enforcement_signal double precision,
    follows_enforcement boolean,
    source_url text,
    rss_guid character varying(500),
    raw_text text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_r3_consultation_status CHECK (((consultation_status)::text = ANY ((ARRAY['Open'::character varying, 'Closed'::character varying, 'Response Published'::character varying, 'Finalised'::character varying])::text[]))),
    CONSTRAINT ck_r3_document_type CHECK (((document_type)::text = ANY ((ARRAY['Consultation'::character varying, 'Guidance'::character varying, 'Audit Framework'::character varying, 'Call for Evidence'::character varying, 'Opinion'::character varying, 'Code of Practice'::character varying])::text[]))),
    CONSTRAINT ck_r3_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_r3_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r3_obligation_direction CHECK (((obligation_direction)::text = ANY ((ARRAY['Tightens'::character varying, 'Relaxes'::character varying, 'Clarifies'::character varying, 'Mixed'::character varying])::text[]))),
    CONSTRAINT ck_r3_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.r3_ico_consultations OWNER TO postgres;

--
-- Name: r4_secondary_regulators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r4_secondary_regulators (
    secondary_id character varying(36) NOT NULL,
    regulator character varying(50) NOT NULL,
    action_date date NOT NULL,
    action_type character varying(50) NOT NULL,
    org_name character varying(500),
    org_type character varying(100),
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    cross_regulator_flag boolean,
    ico_referral boolean,
    enforcement_signal double precision,
    source_url text,
    rss_guid character varying(500),
    raw_text text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_r4_action_type CHECK (((action_type)::text = ANY ((ARRAY['Enforcement'::character varying, 'Investigation'::character varying, 'Guidance'::character varying, 'Market Study'::character varying, 'Statement'::character varying, 'Fine'::character varying, 'Undertaking'::character varying])::text[]))),
    CONSTRAINT ck_r4_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_r4_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r4_regulator CHECK (((regulator)::text = ANY ((ARRAY['CMA'::character varying, 'Ofcom'::character varying, 'FCA'::character varying, 'AI Safety Institute'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_r4_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.r4_secondary_regulators OWNER TO postgres;

--
-- Name: r5_international_bodies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r5_international_bodies (
    international_id character varying(36) NOT NULL,
    body character varying(50) NOT NULL,
    jurisdiction character varying(100) NOT NULL,
    action_date date NOT NULL,
    action_type character varying(50) NOT NULL,
    org_name character varying(500),
    org_type character varying(100),
    penalty_eur numeric(15,2),
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    uk_company_involved boolean,
    gdpr_articles character varying(500),
    ico_signal_strength double precision,
    source_url text,
    gdpr_tracker_id character varying(100),
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_r5_action_type CHECK (((action_type)::text = ANY ((ARRAY['Enforcement Decision'::character varying, 'Binding Opinion'::character varying, 'Guideline'::character varying, 'Joint Investigation'::character varying, 'Urgency Procedure'::character varying, 'Fine'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_r5_body CHECK (((body)::text = ANY ((ARRAY['EDPB'::character varying, 'Irish DPC'::character varying, 'French CNIL'::character varying, 'German BfDI'::character varying, 'Spanish AEPD'::character varying, 'Dutch AP'::character varying, 'Italian Garante'::character varying, 'Polish UODO'::character varying, 'Other'::character varying])::text[]))),
    CONSTRAINT ck_r5_ico_signal CHECK (((ico_signal_strength >= (0)::double precision) AND (ico_signal_strength <= (1)::double precision))),
    CONSTRAINT ck_r5_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r5_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.r5_international_bodies OWNER TO postgres;

--
-- Name: r6_drcf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r6_drcf (
    drcf_id character varying(36) NOT NULL,
    publication_date date NOT NULL,
    document_type character varying(50) NOT NULL,
    title character varying(500) NOT NULL,
    participating_bodies character varying(300),
    processing_activities character varying(500),
    topic_tags character varying(500),
    topic_relevance_score double precision,
    ico_lead boolean,
    enforcement_signal double precision,
    coordinated_action_flag boolean,
    source_url text,
    rss_guid character varying(500),
    raw_text text,
    ingested_at timestamp with time zone,
    nlp_confidence double precision,
    manually_reviewed boolean,
    CONSTRAINT ck_r6_document_type CHECK (((document_type)::text = ANY ((ARRAY['Joint Statement'::character varying, 'Work Programme'::character varying, 'Report'::character varying, 'Consultation Response'::character varying, 'Guidance'::character varying, 'Call for Evidence'::character varying])::text[]))),
    CONSTRAINT ck_r6_enforcement_signal CHECK (((enforcement_signal >= (0)::double precision) AND (enforcement_signal <= (1)::double precision))),
    CONSTRAINT ck_r6_nlp_confidence CHECK (((nlp_confidence >= (0)::double precision) AND (nlp_confidence <= (1)::double precision))),
    CONSTRAINT ck_r6_relevance CHECK (((topic_relevance_score >= (0)::double precision) AND (topic_relevance_score <= (1)::double precision)))
);


ALTER TABLE public.r6_drcf OWNER TO postgres;

--
-- Data for Name: ers_component_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ers_component_scores (score_id, entity_type, entity_id, component, window_days, window_end, raw_score, normalised_score, signal_count, top_signals, computed_at) FROM stdin;
\.


--
-- Data for Name: ers_composite_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ers_composite_scores (composite_id, entity_type, entity_id, window_days, window_end, ers_score, ers_band, regulatory_score, legislative_score, political_score, judicial_score, media_score, complaint_score, w_regulatory, w_legislative, w_political, w_judicial, w_media, w_complaint, weight_version, data_completeness, computed_at) FROM stdin;
55067065-fec6-4e69-b261-30d1d417d7ee	sector	Information Technology	90	2026-04-23	0	Minimal	0	0	0	0	0	0	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0	2026-04-23 14:52:48.620334+01
292ed243-baeb-4ed7-9710-3b757c03a318	sector	Finance, Insurance and Credit	90	2026-04-23	9.12	Minimal	0	0	0	0	0	0.09119999999999999	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.641919+01
45bc21b2-9f3b-488c-b575-aec978183b28	sector	Health	90	2026-04-23	15.14	Low	0	0	0	0	0	0.15139999999999992	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.661951+01
a207f526-551d-4e41-b235-bb5cab91383e	sector	Education and Childcare	90	2026-04-23	4.81	Minimal	0	0	0	0	0	0.04807999999999999	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.693991+01
72aaf2af-e154-40c5-ad37-4ca3c06eeec7	sector	Central Government	90	2026-04-23	14.69	Minimal	0	0	0	0	0	0.14692000000000002	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.739816+01
2f6f263e-4449-445f-bc4c-88357348fc87	sector	Local Government	90	2026-04-23	9.85	Minimal	0	0	0	0	0	0.09847999999999998	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.777906+01
637eab33-d43e-446b-8ea9-62d8cfee613d	sector	Retail and Manufacture	90	2026-04-23	5.68	Minimal	0	0	0	0	0	0.05676000000000001	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.805745+01
74cf5615-12d1-4a09-bf39-21f26c3d6d5e	sector	Telecoms and Internet	90	2026-04-23	8.92	Minimal	0	0	0	0	0	0.08923999999999994	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.826175+01
75bdb600-6d4e-403d-bff3-0baa77e6898b	sector	Political Organisations	90	2026-04-23	21.64	Low	0	0	0	0	0	0.21635999999999997	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.841725+01
aa9f0280-0a20-493b-be42-66fe1d238a86	sector	Media and Publishing	90	2026-04-23	17.86	Low	0	0	0	0	0	0.17856	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.86086+01
fae82fec-ff6b-4573-9b02-90d4aea6a1fe	sector	Legal Services	90	2026-04-23	5.84	Minimal	0	0	0	0	0	0.058440000000000006	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.885141+01
020e3b85-5661-479f-abe8-39afaa90b622	sector	Justice and Emergency Services	90	2026-04-23	13.21	Minimal	0	0	0	0	0	0.13207999999999998	0.25	0.2	0.15	0.2	0.1	0.1	v1_equal	0.16666666666666666	2026-04-23 14:52:48.88752+01
\.


--
-- Data for Name: i1_volume_statistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.i1_volume_statistics (stat_id, period_start, period_end, period_type, ico_sector, sector_relevance, complaint_count, data_breach_count, complaint_resolved, complaint_resolved_pct, yoy_change_pct, qoq_change_pct, avg_3period, pct_above_avg, spike_flag, source_doc, source_url, ingested_at, manually_reviewed, pct_resolved) FROM stdin;
I1-001	2022-01-04	2025-07-03	Annual	Central Government	Partial	1728	94	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-002	2022-01-04	2025-07-03	Annual	Charitable and voluntary	None	653	470	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-003	2022-01-04	2025-07-03	Annual	Education and childcare	Partial	1843	1440	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-004	2022-01-04	2025-07-03	Annual	Finance, insurance and credit	Partial	4210	657	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-005	2022-01-04	2025-07-03	Annual	General business	Full	3991	219	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-006	2022-01-04	2025-07-03	Annual	Health	Partial	3613	2223	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-007	2022-01-04	2025-07-03	Annual	Justice	Partial	1710	125	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-008	2022-01-04	2025-07-03	Annual	Land or property services	None	1702	282	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-009	2022-01-04	2025-07-03	Annual	Legal	None	1109	313	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-010	2022-01-04	2025-07-03	Annual	Local government	Partial	2745	1878	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-011	2022-01-04	2025-07-03	Annual	Marketing	Partial	226	\N	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-012	2022-01-04	2025-07-03	Annual	Media	None	197	31	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-013	2022-01-04	2025-07-03	Annual	Membership association	None	367	63	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-014	2022-01-04	2025-07-03	Annual	Online Technology and Telecoms	Full	3713	344	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-015	2022-01-04	2025-07-03	Annual	Political	Partial	82	\N	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-016	2022-01-04	2025-07-03	Annual	Regulators	Full	282	94	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-017	2022-01-04	2025-07-03	Annual	Religious	None	45	63	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-018	2022-01-04	2025-07-03	Annual	Retail and manufacture	None	2800	1158	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-019	2022-01-04	2025-07-03	Annual	Social care	None	245	626	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-020	2022-01-04	2025-07-03	Annual	Transport and leisure	None	1777	438	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-021	2022-01-04	2025-07-03	Annual	Utilities	None	716	125	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	f	10.6
I1-022	2022-01-04	2025-07-03	Annual	ALL SECTORS (total)	Full	33753	10644	f	\N	\N	\N	\N	\N	f	ICO Annual Report 2022-23	https://ico.org.uk/media2/migrated/4025864/annual-report-2022-23.pdf	2027-05-04 00:00:00+01	t	10.6
I1-023	2023-01-04	2026-07-03	Annual	Central Government	Partial	2034	183	f	\N	17.7	\N	1881	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-024	2023-01-04	2026-07-03	Annual	Charitable and voluntary	None	768	819	f	\N	17.6	\N	710.5	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-025	2023-01-04	2026-07-03	Annual	Education and childcare	Partial	2169	1769	f	\N	17.7	\N	2006	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-026	2023-01-04	2026-07-03	Annual	Finance, insurance and credit	Partial	4954	1349	f	\N	17.7	\N	4582	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-027	2023-01-04	2026-07-03	Annual	General business	Full	4697	311	f	\N	17.7	\N	4344	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-028	2023-01-04	2026-07-03	Annual	Health	Partial	4251	1855	f	\N	17.7	\N	3932	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-029	2023-01-04	2026-07-03	Annual	Justice	Partial	2012	154	f	\N	17.7	\N	1861	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-030	2023-01-04	2026-07-03	Annual	Land or property services	None	2004	545	f	\N	17.7	\N	1853	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-031	2023-01-04	2026-07-03	Annual	Legal	None	1305	850	f	\N	17.7	\N	1207	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-032	2023-01-04	2026-07-03	Annual	Local government	Partial	3230	1055	f	\N	17.7	\N	2987.5	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-033	2023-01-04	2026-07-03	Annual	Marketing	Partial	266	58	f	\N	17.7	\N	246	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-034	2023-01-04	2026-07-03	Annual	Media	None	231	29	f	\N	17.3	\N	214	7.9	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-035	2023-01-04	2026-07-03	Annual	Membership association	None	432	147	f	\N	17.7	\N	399.5	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-036	2023-01-04	2026-07-03	Annual	Online Technology and Telecoms	Full	4369	373	f	\N	17.7	\N	4041	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-037	2023-01-04	2026-07-03	Annual	Political	Partial	96	34	f	\N	17.1	\N	89	7.9	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-038	2023-01-04	2026-07-03	Annual	Regulators	Full	332	45	f	\N	17.7	\N	307	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-039	2023-01-04	2026-07-03	Annual	Religious	None	52	38	f	\N	15.6	\N	48.5	7.2	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-040	2023-01-04	2026-07-03	Annual	Retail and manufacture	None	3296	1206	f	\N	17.7	\N	3048	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-041	2023-01-04	2026-07-03	Annual	Social care	None	288	309	f	\N	17.6	\N	266.5	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-042	2023-01-04	2026-07-03	Annual	Transport and leisure	None	2091	423	f	\N	17.7	\N	1934	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-043	2023-01-04	2026-07-03	Annual	Utilities	None	842	126	f	\N	17.6	\N	779	8.1	f	ICO Annual Report 2023-24; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-044	2023-01-04	2026-07-03	Annual	ALL SECTORS (total)	Full	39721	11680	f	\N	17.7	\N	36737	8.1	f	ICO Annual Report 2023-24	https://ico.org.uk/media/about-the-ico/documents/4030348/annual-report-2023-24.pdf	2027-05-04 00:00:00+01	t	4.9
I1-045	2024-01-04	2027-07-03	Annual	Central Government	Partial	2262	202	f	\N	11.2	\N	2008	12.6	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-046	2024-01-04	2027-07-03	Annual	Charitable and voluntary	None	778	902	f	\N	1.3	\N	733	6.1	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-047	2024-01-04	2027-07-03	Annual	Education and childcare	Partial	1959	1789	f	\N	-9.7	\N	1990.3	-1.6	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-048	2024-01-04	2027-07-03	Annual	Finance, insurance and credit	Partial	4866	1034	f	\N	-1.8	\N	4676.7	4	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-049	2024-01-04	2027-07-03	Annual	General business	Full	3926	294	f	\N	-16.4	\N	4204.7	-6.6	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-050	2024-01-04	2027-07-03	Annual	Health	Partial	4826	2346	f	\N	13.5	\N	4230	14.1	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-051	2024-01-04	2027-07-03	Annual	Justice	Partial	2087	170	f	\N	3.7	\N	1936.3	7.8	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-052	2024-01-04	2027-07-03	Annual	Land or property services	None	2045	655	f	\N	2	\N	1917	6.7	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-053	2024-01-04	2027-07-03	Annual	Legal	None	1255	853	f	\N	-3.8	\N	1223	2.6	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-054	2024-01-04	2027-07-03	Annual	Local government	Partial	3293	1052	f	\N	2	\N	3089.3	6.6	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-055	2024-01-04	2027-07-03	Annual	Marketing	Partial	196	58	f	\N	-26.3	\N	229.3	-14.5	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-056	2024-01-04	2027-07-03	Annual	Media	None	297	24	f	\N	28.6	\N	241.7	22.9	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-057	2024-01-04	2027-07-03	Annual	Membership association	None	531	178	f	\N	22.9	\N	443.3	19.8	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-058	2024-01-04	2027-07-03	Annual	Online Technology and Telecoms	Full	4246	314	f	\N	-2.8	\N	4109.3	3.3	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-059	2024-01-04	2027-07-03	Annual	Political	Partial	146	34	f	\N	52.1	\N	108	35.2	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-060	2024-01-04	2027-07-03	Annual	Regulators	Full	335	47	f	\N	0.9	\N	316.3	5.9	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-061	2024-01-04	2027-07-03	Annual	Religious	None	67	59	f	\N	28.8	\N	54.7	22.5	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-062	2024-01-04	2027-07-03	Annual	Retail and manufacture	None	3135	1403	f	\N	-4.9	\N	3077	1.9	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-063	2024-01-04	2027-07-03	Annual	Social care	None	354	426	f	\N	22.9	\N	295.7	19.7	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-064	2024-01-04	2027-07-03	Annual	Transport and leisure	None	2307	457	f	\N	10.3	\N	2058.3	12.1	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-065	2024-01-04	2027-07-03	Annual	Utilities	None	1090	115	f	\N	29.5	\N	882.7	23.5	f	ICO Annual Report 2024-25; ICO complaints & breach CSVs (proactive disclosure)	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
I1-066	2024-01-04	2027-07-03	Annual	ALL SECTORS (total)	Full	40000	12412	f	\N	0.7	\N	37824.7	5.8	f	ICO Annual Report 2024-25	https://ico.org.uk/media2/1wyfliqp/annual-report-2025-ico-v4-1-complete.pdf	2027-05-04 00:00:00+01	t	2.3
\.


--
-- Data for Name: i2_volume_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.i2_volume_scores (score_id, ico_sector, ref_period_start, ref_period_end, complaint_count_used, avg_3period_used, volume_factor, trend_direction, spike_active, sector_risk_modifier, data_lag, stale_flag, computed_at) FROM stdin;
I2-001	ALL SECTORS (total)	2024-04-01	2025-03-31	40000	37824.7	1.058	Stable	f	1.058	13	t	2026-04-17 00:00:00+01
I2-002	Central Government	2024-04-01	2025-03-31	2262	2008	1.126	Rising	f	1.239	13	t	2026-04-17 00:00:00+01
I2-003	Charitable and voluntary	2024-04-01	2025-03-31	778	733	1.061	Stable	f	1.061	13	t	2026-04-17 00:00:00+01
I2-004	Education and childcare	2024-04-01	2025-03-31	1959	1990.3	0.984	Falling	f	0.886	13	t	2026-04-17 00:00:00+01
I2-005	Finance, insurance and credit	2024-04-01	2025-03-31	4866	4676.7	1.04	Stable	f	1.04	13	t	2026-04-17 00:00:00+01
I2-006	General business	2024-04-01	2025-03-31	3926	4204.7	0.934	Falling	f	0.841	13	t	2026-04-17 00:00:00+01
I2-007	Health	2024-04-01	2025-03-31	4826	4230	1.141	Rising	f	1.255	13	t	2026-04-17 00:00:00+01
I2-008	Justice	2024-04-01	2025-03-31	2087	1936.3	1.078	Rising	f	1.186	13	t	2026-04-17 00:00:00+01
I2-009	Land or property services	2024-04-01	2025-03-31	2045	1917	1.067	Stable	f	1.067	13	t	2026-04-17 00:00:00+01
I2-010	Legal	2024-04-01	2025-03-31	1255	1223	1.026	Falling	f	0.923	13	t	2026-04-17 00:00:00+01
I2-011	Local government	2024-04-01	2025-03-31	3293	3089.3	1.066	Stable	f	1.066	13	t	2026-04-17 00:00:00+01
I2-012	Marketing	2024-04-01	2025-03-31	196	229.3	0.855	Falling	f	0.769	13	t	2026-04-17 00:00:00+01
I2-013	Media	2024-04-01	2025-03-31	297	241.7	1.229	Rising	f	1.352	13	t	2026-04-17 00:00:00+01
I2-014	Membership association	2024-04-01	2025-03-31	531	443.3	1.198	Rising	f	1.318	13	t	2026-04-17 00:00:00+01
I2-015	Online Technology and Telecoms	2024-04-01	2025-03-31	4246	4109.3	1.033	Stable	f	1.033	13	t	2026-04-17 00:00:00+01
I2-016	Political	2024-04-01	2025-03-31	146	108	1.352	Rising	f	1.487	13	t	2026-04-17 00:00:00+01
I2-017	Regulators	2024-04-01	2025-03-31	335	316.3	1.059	Stable	f	1.059	13	t	2026-04-17 00:00:00+01
I2-018	Religious	2024-04-01	2025-03-31	67	54.7	1.225	Rising	f	1.348	13	t	2026-04-17 00:00:00+01
I2-019	Retail and manufacture	2024-04-01	2025-03-31	3135	3077	1.019	Falling	f	0.917	13	t	2026-04-17 00:00:00+01
I2-020	Social care	2024-04-01	2025-03-31	354	295.7	1.197	Rising	f	1.317	13	t	2026-04-17 00:00:00+01
I2-021	Transport and leisure	2024-04-01	2025-03-31	2307	2058.3	1.121	Rising	f	1.233	13	t	2026-04-17 00:00:00+01
I2-022	Utilities	2024-04-01	2025-03-31	1090	882.7	1.235	Rising	f	1.359	13	t	2026-04-17 00:00:00+01
\.


--
-- Data for Name: j1_supreme_court; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.j1_supreme_court (supreme_id, case_name, neutral_citation, decision_date, subject_matter, appellant, respondent, appellant_type, respondent_type, ico_role, ico_position_upheld, outcome_direction, outcome_summary, precedent_weight, processing_activities, gdpr_articles, gdpr_principles, damages_awarded, damages_amount, ai_specific, widens_controller_liability, restricts_ico_powers, enforcement_signal, case_url, ingested_at, nlp_confidence, manually_reviewed, restrict_ico_powers) FROM stdin;
J1-001	Lloyd v Google LLC	[2021] UKSC 50	2021-11-10	Data protection compensation; representative actions; loss of control damages	Lloyd	Google LLC	Data Subject	Controller	None	f	Controller	Supreme Court reversed Court of Appeal and ruled that compensation under DPA 1998 requires proof of material damage or distress — mere breach without proven damage is insufficient. Rejected loss of control/user damages as a standalone head of compensation. Effectively ended mass opt-out data class actions in the UK. Lloyd v Google remains the foundational authority on data breach compensation thresholds under UK law.	Binding	Behavioural advertising; cookie tracking; browser-generated information	DPA 1998 s.13; UK GDPR Article 82 (future application)	Lawfulness fairness and transparency	f	\N	f	f	\N	0.85	https://www.supremecourt.uk/cases/uksc-2019-0213.html	2027-04-04 00:00:00+01	1	t	t
J1-002	Thaler v Comptroller-General of Patents Designs and Trade Marks	[2023] UKSC 49	2023-12-20	AI inventorship; patent law; AI-generated inventions	Thaler	Comptroller-General of Patents	Processor	Government	None	f	Controller	Supreme Court unanimously ruled that only a natural person can be named as inventor on a patent application under the Patents Act 1977 — an autonomous AI system (DABUS) cannot be named as inventor. Ruling confirmed AI system owners cannot derive inventor rights merely from owning the AI. Does not directly engage data protection but has significant implications for AI governance and the accountability framework for AI-generated outputs.	Binding	AI model outputs; AI-generated content; AI development	N/A (Patents Act 1977)	N/A	f	\N	t	f	\N	0.7	https://www.supremecourt.uk/cases/uksc-2021-0201.html	2027-04-04 00:00:00+01	1	t	f
\.


--
-- Data for Name: j2_court_of_appeal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.j2_court_of_appeal (appeal_id, case_name, neutral_citation, decision_date, division, subject_matter, appellant_type, respondent_type, ico_role, ico_position_upheld, outcome_direction, outcome_summary, precedent_weight, processing_activities, gdpr_articles, gdpr_principles, damages_awarded, damages_amount, ai_specific, widens_controller_liability, restricts_ico_powers, enforcement_signal, case_url, ingested_at, nlp_confidence, manually_reviewed, restrict_ico_powers) FROM stdin;
J2-001	DSG Retail Limited v Information Commissioner	[2026] EWCA Civ 140	2027-07-02	Civil	Data security; definition of personal data; controller duty of care; cyber attack	Controller	Regulator	Party (Appellant)	t	ICO	Court of Appeal overturned Upper Tribunal and ruled in ICO's favour. Confirmed that a controller's data security duty applies to all personal data from the controller's perspective — irrespective of whether a third-party attacker could identify individuals from the exfiltrated data. Malware attack on DSG (Currys/Dixons) affecting 5.6m payment cards. ICO's original £500k DPA 1998 fine (max under old regime) substantially upheld in principle. Landmark ruling on definition of personal data in security context.	Binding	Security processing; payment card data processing; retail data processing	DPA 1998 Data Security Principle; UK GDPR Article 5(1)(f); Article 32 (principle application)	Integrity and confidentiality	f	\N	f	t	\N	0.9	https://www.bailii.org/ew/cases/EWCA/Civ/2026/140.html	2027-04-04 00:00:00+01	1	t	f
J2-002	Farley v Paymaster (1836) Ltd (trading as Equiniti)	[2025] EWCA Civ 271	2025-01-03	Civil	Data breach compensation; misdirected personal data; non-material damage; threshold of seriousness	Data Subject	Controller	None	f	Data Subject	Court of Appeal overturned High Court and held that proof of third-party access to misdirected data is not required to establish an infringement of UK GDPR. The act of misdirecting personal data (pension statements sent to wrong addresses) constituted processing and a potential infringement regardless of whether the recipient read it. Also confirmed fear of misuse can constitute non-material damage under Article 82. Widens the basis for data breach compensation claims.	Binding	HR and payroll data processing; pension data; data subject rights	UK GDPR Article 5(1)(f); Article 82; DPA 2018	Integrity and confidentiality	t	\N	f	t	\N	0.8	https://www.bailii.org/ew/cases/EWCA/Civ/2025/271.html	2027-04-04 00:00:00+01	1	t	f
J2-003	Prismall v Google UK Ltd and DeepMind Technologies Ltd	[2024] EWCA Civ 655	2024-01-06	Civil	Representative actions; misuse of private information; health data; NHS data sharing; class cohesion	Data Subject	Controller	None	f	Controller	Court of Appeal upheld High Court dismissal of a representative action brought on behalf of 1.6 million NHS patients whose data was shared with DeepMind without consent. Reaffirmed that representative actions under CPR 19.8 require claimants to have the 'same interest' — diverse individual circumstances of harm made this impossible to satisfy. Confirmed Lloyd v Google's approach applies to misuse of private information as well as data protection claims. Significantly restricts mass privacy representative actions.	Binding	Health data processing; data sharing; NHS data; research processing	UK GDPR Article 6; Article 9; DPA 2018 Schedule 1	Lawfulness fairness and transparency; Data minimisation	f	\N	f	f	\N	0.75	https://www.bailii.org/ew/cases/EWCA/Civ/2024/655.html	2027-04-04 00:00:00+01	1	t	f
J2-004	Stoute v News Group Newspapers	[2023] EWCA Civ 523	2023-01-05	Civil	Misuse of private information; reasonable expectation of privacy; photographs in public places; interim injunctions	Data Subject	Controller	None	f	Mixed	Court of Appeal considered reasonable expectation of privacy for photographs taken on a public beach by paparazzi. Upheld High Court refusal of interim injunction. Reaffirmed that even in public places some expectation of privacy can exist in limited circumstances but claimants must demonstrate it clearly. Peripheral to ICO enforcement but relevant to data subjects' rights landscape.	Binding	Journalistic processing; photography; personal data in media	UK GDPR Article 85; DPA 2018 Schedule 2 Part 5 (journalism exemption)	Lawfulness fairness and transparency	f	\N	f	f	\N	0.55	https://www.bailii.org/ew/cases/EWCA/Civ/2023/523.html	2027-04-04 00:00:00+01	1	t	f
\.


--
-- Data for Name: j3_information_rights_tribunal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.j3_information_rights_tribunal (tribunal_id, case_reference, tier, decision_date, case_type, appellant_type, ico_role, ico_position_upheld, outcome_direction, original_penalty_gbp, revised_penalty_gbp, penalty_reduction_pct, appeals_ground, processing_activities, gdpr_articles, ai_specific, precedent_weight, enforcement_signal, case_url, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
J3-001	EA/2023/0167	First-tier	2024-01-05	Monetary Penalty Appeal	Controller	Respondent	t	ICO	130000.00	130000.00	0	Consent validity; adequacy of privacy notice; whether registration constitutes consent to direct marketing	Direct marketing; consent management	PECR Regulation 22; UK GDPR Article 4(11)	f	Persuasive	0.7	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/05/first-tier-tribunal-ruling-on-join-the-triboo-appeal/	2027-04-04 00:00:00+01	1	t
J3-002	EA/2022/0154	First-tier	2024-08-02	Enforcement Notice Appeal	Controller	Respondent	f	Controller	\N	\N	\N	Legitimate interests as lawful basis for direct marketing; transparency obligations; fairness of processing for data brokers	Direct marketing profiling; data brokerage	UK GDPR Article 5(1)(a); Article 6(1)(f); Article 14	f	Persuasive	0.6	https://www.fieldfisher.com/en/insights/the-transparency-and-legitimate-interests-battle-in-direct-marketing-ico-to-appeal-first-tier-tribunal-decision-in-experian-v-the-information-commissioner-2023	2027-04-04 00:00:00+01	1	t
J3-003	UA/2023/0147	Upper Tribunal	2024-01-04	Enforcement Notice Appeal	Controller	Respondent	f	Controller	\N	\N	\N	Legitimate interests as lawful basis; transparency of processing; whether ICO evidence sufficient to support original enforcement notice	Direct marketing profiling; data brokerage	UK GDPR Article 5(1)(a); Article 6(1)(f); Article 14	f	Binding	0.5	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/04/ico-statement-on-upper-tribunal-ruling/	2027-04-04 00:00:00+01	1	t
J3-004	EA/2022/0224 (FTT); UA/2024/0032 (UT)	Upper Tribunal	2025-08-10	Monetary Penalty Appeal	Controller	Respondent	t	ICO	7500000.00	7500000.00	0	Territorial jurisdiction of UK GDPR; whether processing by foreign company for foreign law enforcement clients falls within material scope of UK GDPR; Article 2 exemption	Biometric data processing; web scraping; facial recognition; AI training	UK GDPR Article 2; Article 3; Article 5; Article 6; Article 9; Article 14	t	Binding	0.9	https://iclg.com/news/23159-tribunal-sides-with-ico-in-gdpr-dispute	2027-04-04 00:00:00+01	1	t
J3-005	EA/2023/0089	First-tier	2026-09-05	Monetary Penalty Appeal	Controller	Respondent	t	ICO	12700000.00	12700000.00	0	Whether ICO had jurisdiction to issue MPN given TikTok's claim that processing was for artistic purposes (special purposes exemption under DPA 2018)	Children's data processing; consent management; transparency; social media	UK GDPR Article 5(1)(a); Article 8; Article 12; Article 13	f	Persuasive	0.8	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2025/07/ico-welcomes-tribunal-ruling-on-preliminary-issue-raised-by-tiktok-in-its-appeal-of-2023-penalty/	2027-04-04 00:00:00+01	1	t
J3-006	UA/2024/0012	Upper Tribunal	2025-08-10	Monetary Penalty Appeal	Controller	Respondent	t	ICO	7500000.00	7500000.00	0	Territorial jurisdiction of UK GDPR; whether processing by foreign company for foreign law enforcement clients falls within material scope; Article 2 and Article 3 scope; monitoring of UK residents	Biometric data processing; facial recognition; web scraping; AI training data	UK GDPR Article 2; Article 3; Article 5; Article 6; Article 9; Article 14	t	Binding	0.9	https://www.bailii.org/uk/cases/UKUT/AAC/2025/clearview.html	2027-04-04 00:00:00+01	1	t
J3-007	EA/2024/0031	First-tier	2024-01-08	Information Notice Appeal	Controller	Respondent	t	ICO	\N	\N	\N	Whether HMRC was required to disclose information about use of AI in reviewing R&D tax credit claims; transparency obligations in AI-assisted decision-making by public bodies	Automated decision-making; AI-assisted tax assessment; R&D claims processing	UK GDPR Article 13; Article 14; Article 22; FOIA 2000	t	Persuasive	0.75	https://www.bailii.org/uk/cases/UKFTT/GRC/2024/hmrc-ai-rd.html	2027-04-04 00:00:00+01	1	t
J3-008	EA/2023/0201	First-tier	2024-01-05	Monetary Penalty Appeal	Controller	Respondent	t	ICO	750000.00	750000.00	0	Adequacy of security measures for FOI response; whether exposing hidden worksheet constitutes inadequate organisational measures; DPA 2018 Part 3 obligations on law enforcement bodies	HR data processing; law enforcement workforce data; FOI disclosure	DPA 2018 Part 3; security principle equivalent to Article 5(1)(f)	f	Persuasive	0.7	https://www.bailii.org/uk/cases/UKFTT/GRC/2024/psni.html	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: j4_high_court; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.j4_high_court (highcourt_id, case_name, neutral_citation, decision_date, division, case_type, ico_role, ico_position_upheld, jr_permission_granted, outcome_direction, outcome_summary, precedent_weight, processing_activities, gdpr_articles, gdpr_principles, damages_awarded, damages_amount, ai_specific, widens_controller_liability, restricts_ico_powers, enforcement_signal, case_url, ingested_at, nlp_confidence, manually_reviewed, restrict_ico_powers) FROM stdin;
J4-001	Farley v Paymaster (1836) Ltd (trading as Equiniti)	[2024] EWHC 383 (KB)	2024-01-02	King's Bench	Civil Damages Claim	None	f	f	Controller	High Court struck out claims finding that proof of third-party access to misdirected pension statements was required for an infringement to be established. Held claimants who could not show statements were opened had no real prospect of success. Later overturned by Court of Appeal in 2025 (see J2-002) which held the act of misdirection itself constitutes processing and a potential infringement.	Persuasive	Pension data processing; HR payroll data; data subject rights	UK GDPR Article 5(1)(f); Article 82	Integrity and confidentiality	t	\N	f	f	\N	0.7	https://www.bailii.org/ew/cases/EWHC/KB/2024/383.html	2027-04-04 00:00:00+01	1	t	f
J4-002	Getty Images (US) Inc v Stability AI Ltd	[2023] EWHC 3090 (Ch)	2023-01-12	Chancery	Civil Damages Claim	None	f	f	Mixed	High Court refused to strike out Getty's claims that Stability AI unlawfully scraped millions of images to train its Stable Diffusion model in breach of copyright and database rights. Held the claims had a reasonable prospect of success. Case has significant implications for lawful basis for AI training data under UK GDPR as well as copyright. Trial judgment expected 2025-2026.	Persuasive	AI training data; web scraping; image processing; generative AI development	UK GDPR Article 6 (lawful basis for scraping); Article 5(1)(a)	Lawfulness fairness and transparency	f	\N	t	f	\N	0.85	https://www.bailii.org/ew/cases/EWHC/Ch/2023/3090.html	2027-04-04 00:00:00+01	1	t	f
J4-003	Prismall v Google UK Ltd and DeepMind Technologies Ltd	[2023] EWHC 1169 (KB)	2023-01-05	King's Bench	Civil Damages Claim	None	f	f	Controller	High Court dismissed representative misuse of private information claim brought on behalf of 1.6 million NHS patients whose data was shared with DeepMind without consent. Held claimants could not satisfy 'same interest' test for representative action — diversity of individual circumstances was fatal. Confirmed Lloyd v Google applies to misuse of private information. Appealed to Court of Appeal (see J2-003).	Persuasive	Health data processing; data sharing; NHS data; research processing	UK GDPR Article 6; Article 9	Lawfulness fairness and transparency	f	\N	f	f	\N	0.75	https://www.bailii.org/ew/cases/EWHC/KB/2023/1169.html	2027-04-04 00:00:00+01	1	t	f
J4-004	Gambling operator v data subject (online casino profiling case)	[2025] EWHC (KB)	2025-01-06	King's Bench	Civil Damages Claim	None	f	f	Data Subject	High Court found online gambling operator liable for unlawfully profiling a problem gambler for personalised direct marketing without valid consent. Held that consent must be assessed in its full sectoral context with heightened standards where vulnerability is present. Introduced novel three-part consent test incorporating subjective and autonomy-based elements beyond UK GDPR text. Operator granted permission to appeal to Court of Appeal in March 2025.	Persuasive	Direct marketing profiling; behavioural profiling; gambling sector data processing	UK GDPR Article 6(1)(a); Article 7; Article 4(11)	Lawfulness fairness and transparency	t	\N	f	t	\N	0.8	https://www.bailii.org/ew/cases/EWHC/KB/2025/gambling-profiling.html	2027-04-04 00:00:00+01	1	t	f
\.


--
-- Data for Name: l1_bills_in_parliament; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.l1_bills_in_parliament (bill_id, parliament_bill_id, bill_type, bill_title, session, event_type, event_date, house, bill_stage_numeric, bill_status, expected_commencement, processing_activities, relevance_score, relevance_tag, nlp_confidence, obligation_direction, affects_ico, source_url, rss_guid, ingested_at, manually_reviewed) FROM stdin;
L1-001	3825	Government	Data (Use and Access) Act 2025	2024-2026	Lords Introduction	2025-11-10	Lords	1	Passed	2025-08-20	Data protection; automated decision-making; PECR; smart data; digital identity; cookies; international transfers	0.98	DUAA; data protection reform; UK GDPR amendment; PECR reform; ADM; ICO governance; smart data; cookies	1	Mixed	t	https://bills.parliament.uk/bills/3825	\N	2026-04-16 00:00:00+01	t
L1-002	3825	Government	Data (Use and Access) Act 2025	2024-2026	Second Reading	2024-06-11	Lords	2	Passed	2025-08-20	Data protection; automated decision-making; PECR; smart data; digital identity; cookies	0.98	DUAA; data protection reform; UK GDPR amendment; Lords second reading	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-003	3825	Government	Data (Use and Access) Act 2025	2024-2026	Committee Stage	2026-10-01	Lords	3	Passed	2025-08-20	Data protection; automated decision-making; PECR; AI copyright; smart data	0.98	DUAA; Lords committee; AI copyright amendment; Baroness Kidron; data protection reform	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-004	3825	Government	Data (Use and Access) Act 2025	2024-2026	Report Stage	2025-12-03	Lords	4	Passed	2025-08-20	Data protection; automated decision-making; PECR; AI copyright; smart data; digital identity	0.98	DUAA; Lords report; data protection; AI copyright; recognised legitimate interests	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-005	3825	Government	Data (Use and Access) Act 2025	2024-2026	Third Reading	2025-02-04	Lords	5	Passed	2025-08-20	Data protection; PECR; smart data; digital identity; ICO governance	0.98	DUAA; Lords third reading; data protection reform	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-006	3825	Government	Data (Use and Access) Act 2025	2024-2026	First Reading	2025-09-04	Commons	6	Passed	2025-08-20	Data protection; PECR; smart data; digital identity	0.98	DUAA; Commons first reading; data protection reform	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-007	3825	Government	Data (Use and Access) Act 2025	2024-2026	Second Reading	2026-10-04	Commons	7	Passed	2025-08-20	Data protection; automated decision-making; PECR; cookies; AI copyright	0.98	DUAA; Commons second reading; data protection reform; ADM; cookies	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-008	3825	Government	Data (Use and Access) Act 2025	2024-2026	Committee Stage	2025-07-05	Commons	8	Passed	2025-08-20	Data protection; automated decision-making; PECR; smart data; AI copyright	0.98	DUAA; Commons committee; data protection reform; AI copyright; Baroness Kidron amendment	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-009	3825	Government	Data (Use and Access) Act 2025	2024-2026	Report Stage	2026-07-05	Commons	9	Passed	2025-08-20	Data protection; PECR; smart data; digital identity; ADM	0.98	DUAA; Commons report stage; data protection reform	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-010	3825	Government	Data (Use and Access) Act 2025	2024-2026	Third Reading	2025-04-06	Commons	10	Passed	2025-08-20	Data protection; PECR; smart data; digital identity; ADM; ICO governance	0.98	DUAA; Commons third reading; data protection reform	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-011	3825	Government	Data (Use and Access) Act 2025	2024-2026	Ping Pong	2025-11-06	Both	11	Passed	2025-08-20	Data protection; AI copyright; PECR; smart data	0.98	DUAA; ping pong; Lords message; AI copyright assurances; consideration of amendments	1	Mixed	t	https://bills.parliament.uk/bills/3825/stages	\N	2026-04-16 00:00:00+01	t
L1-012	3825	Government	Data (Use and Access) Act 2025	2024-2026	Royal Assent	2026-07-06	Both	12	Passed	2025-08-20	Data protection; automated decision-making; PECR; smart data; digital identity; cookies; ICO governance	0.98	DUAA; royal assent; Data Use and Access Act 2025; data protection reform; ICO governance	1	Increases	t	https://www.legislation.gov.uk/ukpga/2025/18	\N	2026-04-16 00:00:00+01	t
L1-013	3137	Government	Online Safety Act 2023	2022-2023	First Reading	2023-05-03	Commons	1	Passed	2024-01-01	Children's data processing; content moderation; age assurance; platform obligations; user data	0.85	Online Safety Act; OSA; children's safety; age assurance; user-to-user services; content moderation	1	Increases	f	https://bills.parliament.uk/bills/3137	\N	2026-04-16 00:00:00+01	t
L1-014	3137	Government	Online Safety Act 2023	2022-2023	Second Reading	2023-07-04	Commons	2	Passed	2024-01-01	Children's data processing; content moderation; age assurance; platform obligations	0.85	Online Safety Act; OSA; children's safety; age assurance; second reading	1	Increases	f	https://bills.parliament.uk/bills/3137/stages	\N	2026-04-16 00:00:00+01	t
L1-015	3137	Government	Online Safety Act 2023	2022-2023	Committee Stage	2025-01-04	Commons	3	Passed	2024-01-01	Children's data processing; content moderation; age assurance; self-harm offences	0.85	Online Safety Act; OSA; committee stage; children's safety; self-harm offence added	1	Increases	f	https://bills.parliament.uk/bills/3137/stages	\N	2026-04-16 00:00:00+01	t
L1-016	3137	Government	Online Safety Act 2023	2022-2023	Third Reading	2023-06-09	Lords	10	Passed	2024-01-01	Children's data processing; age verification; content moderation; pornography age assurance	0.85	Online Safety Act; OSA; Lords third reading; age verification; children's safety	1	Increases	f	https://bills.parliament.uk/bills/3137/stages	\N	2026-04-16 00:00:00+01	t
L1-017	3137	Government	Online Safety Act 2023	2022-2023	Royal Assent	2025-02-10	Both	12	Passed	2024-01-01	Children's data processing; age assurance; content moderation; user-to-user services; platform data	0.85	Online Safety Act; OSA; royal assent; online safety; children's safety; age assurance; Ofcom enforcement	1	Increases	f	https://www.legislation.gov.uk/ukpga/2023/50	\N	2026-04-16 00:00:00+01	t
L1-018	3548	Government	Digital Markets Competition and Consumers Act 2024	2023-2024	Royal Assent	2025-12-05	Both	12	Passed	2025-01-01	Consumer data processing; digital markets; competition; platform data access; SMS obligations	0.78	DMCCA; Digital Markets Competition and Consumers Act; CMA powers; strategic market status; consumer protection	1	Increases	f	https://www.legislation.gov.uk/ukpga/2024/13	\N	2026-04-16 00:00:00+01	t
L1-019	1111	Government	UK General Data Protection Regulation (UK GDPR)	2017-2019	Royal Assent	2019-11-05	Both	12	Passed	2018-05-25	All personal data processing activities	1	UK GDPR; GDPR; data protection; lawful basis; data subject rights; ICO enforcement; primary legislation	1	Increases	t	https://www.legislation.gov.uk/eur/2016/679	\N	2026-04-16 00:00:00+01	t
L1-020	1111	Government	UK General Data Protection Regulation (UK GDPR)	2020-2021	Royal Assent	2021-01-01	Both	12	Passed	2021-01-01	All personal data processing activities	1	UK GDPR; Brexit; retained EU law; EUWA 2018; UK data protection; ICO enforcement	1	Clarifies	t	https://www.legislation.gov.uk/eur/2016/679/contents	\N	2026-04-16 00:00:00+01	t
L1-021	1111	Government	Data Protection Act 2018	2017-2019	Lords Introduction	2018-01-09	Lords	1	Passed	2018-05-25	All personal data processing; law enforcement processing; intelligence services processing	1	DPA 2018; data protection; ICO enforcement; law enforcement processing; intelligence services; primary legislation	1	Increases	t	https://bills.parliament.uk/bills/1849	\N	2026-04-16 00:00:00+01	t
L1-022	1111	Government	Data Protection Act 2018	2017-2019	Royal Assent	2019-11-05	Both	12	Passed	2018-05-25	All personal data processing; law enforcement processing; intelligence services processing; ICO regulatory functions	1	DPA 2018; data protection; royal assent; ICO enforcement; law enforcement processing; GDPR supplement; primary legislation	1	Increases	t	https://www.legislation.gov.uk/ukpga/2018/12	\N	2026-04-16 00:00:00+01	t
L1-023	SI 2003/2426	Government	Privacy and Electronic Communications (EC Directive) Regulations 2003 (PECR)	2002-2003	Royal Assent	2004-06-09	Both	12	Passed	2003-12-11	Electronic marketing; cookies; electronic communications; spam; direct marketing by phone email text fax	1	PECR; Privacy and Electronic Communications Regulations; cookies; direct marketing; spam; electronic communications; ICO enforcement; primary enforcement legislation	1	Increases	t	https://www.legislation.gov.uk/uksi/2003/2426	\N	2026-04-16 00:00:00+01	t
\.


--
-- Data for Name: l2_statutory_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.l2_statutory_instruments (si_id, si_number, si_title, si_type, parent_act_id, parent_act_name, made_date, laid_date, force_date, provisions_commenced, si_status, processing_activities, relevance_score, relevance_tag, nlp_confidence, obligation_type, affects_ico, source_url, rss_guid, ingested_at, manually_reviewed, days_to_force) FROM stdin;
L2-001	SI 2025/904	Data (Use and Access) Act 2025 (Commencement No. 1) Regulations 2025	Commencement Order	L1-012	Data (Use and Access) Act 2025	2026-02-08	2026-02-08	2026-08-08	Part 1 (Smart Data schemes); Section 72 (international transfers); Section 111 (PECR breach notification aligned to UK GDPR); ICO new statutory objectives (Part 6); AI and copyright reporting duties	In Force	Smart data processing; PECR breach notification; international data transfers; ICO regulatory functions	0.95	DUAA commencement 1; smart data; PECR reform; ICO statutory objectives; international transfers; AI copyright	1	New ICO power; New duty	t	https://www.legislation.gov.uk/uksi/2025/904/made	\N	2027-04-04 00:00:00+01	t	6
L2-002	SI 2025/967	Data (Use and Access) Act 2025 (Commencement No. 2) Regulations 2025	Commencement Order	L1-012	Data (Use and Access) Act 2025	2027-01-09	2027-01-09	2027-06-09	Section 124 (amendment to Online Safety Act 2023 — retention of information in child death investigations by internet service providers)	In Force	Information retention by online platforms; child death investigation data; Ofcom direction powers	0.82	DUAA commencement 2; Online Safety Act amendment; child death investigation; information retention; Ofcom	1	New duty	f	https://www.legislation.gov.uk/uksi/2025/967/made	\N	2027-04-04 00:00:00+01	t	5
L2-003	SI 2025/989	Data (Use and Access) Act 2025 (Commencement No. 3 and Transitional and Saving Provisions) Regulations 2025	Commencement Order	L1-012	Data (Use and Access) Act 2025	2025-01-09	2025-01-09	2025-05-09	Section 79 (legal professional privilege in law enforcement data processing); Sections 88-90 (national security processing amendments to DPA 2018 Parts 3 and 4)	In Force	Law enforcement data processing; national security data processing; legal professional privilege	0.8	DUAA commencement 3; law enforcement processing; national security; DPA 2018 Part 3; DPA 2018 Part 4	1	Clarification; Removal of exemption	t	https://www.legislation.gov.uk/uksi/2025/989/made	\N	2027-04-04 00:00:00+01	t	4
L2-004	SI 2025/1089	Data (Use and Access) Act 2025 (Commencement No. 4) Regulations 2025	Commencement Order	L1-012	Data (Use and Access) Act 2025	2027-03-11	2027-03-11	2025-01-12	Part 2 (digital identity and attributes trust framework; statutory register of digital identity service providers; Office for Digital Identities and Attributes)	In Force	Digital identity data processing; identity verification; digital attributes; trust framework	0.85	DUAA commencement 4; digital identity; DVS trust framework; identity verification; OFDIA; digital verification services	1	New duty	f	https://www.legislation.gov.uk/uksi/2025/1089/made	\N	2027-04-04 00:00:00+01	t	4
L2-005	SI 2026/87	Data (Use and Access) Act 2025 (Commencement No. 5) Regulations 2026	Commencement Order	L1-012	Data (Use and Access) Act 2025	2026-03-02	2026-03-02	2026-06-02	Section 138 (new offences relating to creating or requesting creation of purported intimate images of an adult without consent — deepfake intimate images)	In Force	Deepfake intimate image processing; non-consensual intimate images; AI-generated images	0.88	DUAA commencement 5; deepfake images; NCII; non-consensual intimate images; AI-generated content; new criminal offence	1	New duty	f	https://www.legislation.gov.uk/uksi/2026/87/made	\N	2027-04-04 00:00:00+01	t	3
L2-006	SI 2026/112	Data (Use and Access) Act 2025 (Commencement No. 6 and Transitional and Saving Provisions) Regulations 2026	Commencement Order	L1-012	Data (Use and Access) Act 2025	2028-05-01	2028-05-01	2026-05-02	Majority of Part 5 data protection provisions including: ADM reforms (Article 22 equivalent narrowed to special category data); DSAR reasonable and proportionate search; recognised legitimate interests; cookie consent exemptions for analytics; international transfer reforms; scientific research statutory definition; new special category data powers for Secretary of State; PECR penalty uplift to UK GDPR levels	In Force	Automated decision-making; data subject access requests; cookies; international transfers; legitimate interests; PECR enforcement; scientific research processing	0.98	DUAA commencement 6; ADM reform; Article 22; DSAR; cookies; recognised legitimate interests; international transfers; PECR uplift; ICO enforcement; scientific research	1	New duty; New ICO power; Penalty uplift; Clarification	t	https://www.legislation.gov.uk/uksi/2026/112/made	\N	2027-04-04 00:00:00+01	t	7
L2-007	SI 0000/00	Data (Use and Access) Act 2025 (Commencement No. 7 — Complaints Procedure) Regulations 2026	Commencement Order	L1-012	Data (Use and Access) Act 2025	\N	\N	2027-07-06	Section 103 (new Section 164A DPA 2018 — mandatory complaints handling procedure: organisations must establish formal process for data subjects to complain before escalating to ICO)	Made	Data subject complaints handling; organisational data protection governance; ICO complaint gateway	0.9	DUAA commencement 7; complaints procedure; Section 164A DPA 2018; data subject complaints; ICO gateway; June 2026	1	New duty	t	https://www.gov.uk/guidance/data-use-and-access-act-2025-plans-for-commencement	\N	2027-04-04 00:00:00+01	t	\N
L2-008	SI 0000/01	Data (Use and Access) Act 2025 (Commencement No. 8 — ICO Governance) Regulations 2026	Commencement Order	L1-012	Data (Use and Access) Act 2025	\N	\N	2026-01-09	Part 6 ICO governance restructuring: establishment of the Information Commission; appointment of Board members; transition from ICO to Information Commission	Made	ICO regulatory governance; Information Commission establishment; Board appointments	0.9	DUAA commencement 8; Information Commission; ICO governance; Board appointments; ICO restructure	1	New ICO power	t	https://www.gov.uk/guidance/data-use-and-access-act-2025-plans-for-commencement	\N	2027-04-04 00:00:00+01	t	\N
L2-009	SI 2024/49	Online Safety Act 2023 (Commencement No. 4) Regulations 2024	Commencement Order	L1-017	Online Safety Act 2023	2024-12-01	2024-12-01	2025-05-01	Part 5 (duties on providers of pornographic content): highly effective age assurance requirements for providers of online pornographic material	In Force	Age verification data processing; adult content platforms; children's access restriction; age assurance	0.82	OSA commencement 4; age assurance; pornography; Part 5; highly effective age assurance; HEAA; Ofcom enforcement	1	New duty	f	https://www.legislation.gov.uk/uksi/2024/49/made	\N	2027-04-04 00:00:00+01	t	5
L2-010	SI 2025/198	Online Safety Act 2023 (Commencement No. 6) Regulations 2025	Commencement Order	L1-017	Online Safety Act 2023	2025-11-03	2025-11-03	2026-05-03	Illegal content duties: user-to-user services and search services must implement measures to identify and remove illegal content; illegal harms codes of practice in force	In Force	Content moderation; illegal content processing; user data for content moderation; risk assessments	0.82	OSA commencement 6; illegal content duties; Illegal Content Codes; risk assessment; user-to-user services; Ofcom enforcement	1	New duty	f	https://www.legislation.gov.uk/uksi/2025/198/made	\N	2027-04-04 00:00:00+01	t	6
L2-011	SI 2025/467	Online Safety Act 2023 (Commencement No. 7) Regulations 2025	Commencement Order	L1-017	Online Safety Act 2023	2025-01-07	2025-01-07	2027-01-07	Children's duties under the Protection of Children Codes: all remaining children's safety obligations enforceable including recommender system duties and default settings requirements	In Force	Children's data processing; recommender systems; default privacy settings; age assurance; children's safety	0.88	OSA commencement 7; Protection of Children Codes; children's duties; recommender systems; default settings; age assurance; Ofcom enforcement	1	New duty	f	https://www.legislation.gov.uk/uksi/2025/467/made	\N	2027-04-04 00:00:00+01	t	24
L2-012	SI 2019/419	Data Protection, Privacy and Electronic Communications (Amendments etc) (EU Exit) Regulations 2019	Amendment SI	L1-022	European Union (Withdrawal) Act 2018; GDPR; DPA 2018	2021-04-02	2021-04-02	2022-07-01	Creates UK GDPR as a retained version of EU GDPR with UK-specific modifications; amends DPA 2018 and PECR to reflect Brexit; establishes ICO as the competent authority for UK data protection post-Brexit	In Force	All personal data processing activities subject to UK GDPR; international data transfers; ICO regulatory functions	1	UK GDPR; Brexit; retained EU law; GDPR domestication; ICO; data protection reform; EU Exit SI	1	Clarification; new ICO power	t	https://www.legislation.gov.uk/uksi/2019/419	\N	2027-04-04 00:00:00+01	t	337
L2-013	SI 2018/625	Data Protection Act 2018 (Commencement No. 1 and Transitional and Saving Provisions) Regulations 2018	Commencement Order	L1-022	Data Protection Act 2018	2019-11-05	2019-11-05	2020-01-05	Majority of DPA 2018 provisions; Part 2 (supplement to GDPR); Part 3 (law enforcement processing); Part 4 (intelligence services); Part 5 (ICO); Part 6 (enforcement including monetary penalties and prosecution)	In Force	All personal data processing; law enforcement processing; intelligence services processing; ICO enforcement powers	1	DPA 2018; commencement; law enforcement; intelligence services; ICO enforcement; monetary penalties; primary enforcement legislation	1	New duty; new ICO power	t	https://www.legislation.gov.uk/uksi/2018/625	\N	2027-04-04 00:00:00+01	t	2
L2-014	SI 2003/2426	Privacy and Electronic Communications (EC Directive) Regulations 2003	Regulatory Reform Order	L1-023	European Communities Act 1972 (implementing EU ePrivacy Directive 2002/58/EC)	2004-06-09	2004-06-09	2003-11-12	Full PECR regime: Regulations 19-24 (electronic marketing consent rules for email text fax automated calls); Regulations 5-8 (cookies and similar technologies); Regulations 21 and 26 (TPS and CTPS); ICO enforcement powers for PECR breaches up to £500k	In Force	Electronic marketing processing; cookie and tracking technology processing; direct marketing by electronic means; telephone preference scheme	1	PECR; Privacy and Electronic Communications Regulations 2003; cookies; direct marketing; spam; TPS; CTPS; ICO enforcement; electronic marketing; primary enforcement tool	1	New duty; new ICO power	t	https://www.legislation.gov.uk/uksi/2003/2426	\N	2027-04-04 00:00:00+01	t	84
L2-015	SI 2011/1208	Privacy and Electronic Communications (EC Directive) (Amendment) Regulations 2011	Amendment SI	L1-023	Privacy and Electronic Communications (EC Directive) Regulations 2003	2011-04-05	2011-04-05	2013-02-05	Regulation 6 amendment: strengthened cookie consent rules requiring prior informed consent before placing cookies (except strictly necessary); removes soft opt-in for cookies; implements revised EU ePrivacy Directive 2009/136/EC	In Force	Cookie processing; online tracking; behavioural advertising; website analytics	0.9	PECR amendment; cookies; consent; ePrivacy Directive; cookie law; ICO enforcement	1	New duty	t	https://www.legislation.gov.uk/uksi/2011/1208	\N	2027-04-04 00:00:00+01	t	22
\.


--
-- Data for Name: m1_ngo_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.m1_ngo_activity (ngo_activity_id, ngo_name, publication_date, activity_type, title, source_url, target_org, ico_named, formal_complaint, complaint_ref, legal_action, content_summary, processing_activities, topic_relevance_score, enforcement_stance, gdpr_articles, ingested_at, nlp_confidence, manually_reviewed, ngo_id, activity_date, organisation, org_type, summary, topic_tags, target_organisation, target_type, ico_complaint_raised, outcome, enforcement_signal) FROM stdin;
M1-001	Big Brother Watch	2024-11-05	Report	Biometric Britain: The Expansion of Facial Recognition Surveillance	https://bigbrotherwatch.org.uk/wp-content/uploads/2023/05/Biometric-Britain.pdf	Metropolitan Police; South Wales Police; Home Office	\N	f	\N	f	Report documenting rapid growth in police use of live facial recognition. Found 86%+ inaccuracy rates in Met and South Wales Police deployments. Called for moratorium on LFR pending a statutory framework. Included briefing for DPDI Bill committee stage.	Biometric data processing; facial recognition; police surveillance; special category data	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	facial recognition; biometrics; police surveillance; LFR; DPDI Bill; inaccuracy; moratorium	\N	Public authority	\N		0.8
M1-002	Big Brother Watch	2024-08-07	Formal Complaint	Complaint to ICO re welfare fraud-scoring algorithms	https://bigbrotherwatch.org.uk/press-releases/councils-hidden-algorithms-profile-millions-on-benefits-big-brother-watch-investigation-finds/	Multiple local authorities; DWP	\N	t	\N	f	Formal ICO complaint following Poverty Panopticon investigation. Found 540000 benefit applicants secretly assigned fraud-risk scores; 1.6 million people in social housing profiled by commercial algorithms. Argued processing lacked lawful basis and violated fairness and transparency principles.	Automated decision-making; welfare data processing; profiling; algorithmic scoring	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	ADM; welfare; algorithms; fraud scoring; profiling; local authorities; UK GDPR; ICO complaint	\N	Public authority	\N	ICO acknowledged complaint; no enforcement action confirmed by end 2024	0.75
M1-003	Big Brother Watch	2023-08-03	Parliamentary Submission	Briefing on DPDI Bill No.2 for House of Commons Committee Stage	https://bigbrotherwatch.org.uk/wp-content/uploads/2023/05/Big-Brother-Watch-Briefing-on-the-Data-Protection-and-Digital-Information-2.0-Bill-for-House-of-Commons-Committee-Stage.pdf	DSIT; Parliament	\N	f	\N	f	Argued DPDI Bill weakened data subject rights including rights against automated decisions; would undermine ICO independence; proposed amendments to restore UK GDPR protections including ADM safeguards. Filed alongside Liberty and ORG.	Automated decision-making; data subject rights; ICO independence; UK GDPR	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	DPDI Bill; ADM; data subject rights; ICO independence; UK GDPR reform; parliamentary briefing	\N	Government	\N		0.7
M1-004	Big Brother Watch	2025-07-09	Report	Bossware: The Dangers of High Tech Worker Surveillance	https://bigbrotherwatch.org.uk/wp-content/uploads/2024/09/BosswareWebVersion.pdf	UK employers generally	\N	f	\N	f	Report exposing use of AI-powered workplace monitoring tools by UK employers. Documented employee tracking through keystroke logging; screen capture; biometric attendance monitoring. Called for statutory ban on covert employee surveillance and ICO enforcement action.	Employment data processing; workplace surveillance; biometric data; employee monitoring	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	bossware; workplace surveillance; employee data; ICO enforcement; biometric attendance; AI monitoring	\N	Private sector	\N		0.72
M1-005	Big Brother Watch	2025-07-08	Legal Challenge	Police facial recognition searches of passport database legal challenge	https://bigbrotherwatch.org.uk/press-releases/passport-searches/	Home Office; police forces	\N	f	\N	t	Announced judicial review against Home Office and police forces over secret use of facial recognition to search passport database. FOI data showed searches skyrocketed from 2 in 2020 to 417 in 2023. Argued unlawful mass biometric surveillance without statutory framework or public knowledge.	Biometric data processing; facial recognition; passport database; police surveillance	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	facial recognition; passport database; police; Home Office; judicial review; biometrics; mass surveillance	\N	Public authority	\N	Legal challenge filed; ongoing at April 2026	0.85
M1-006	Big Brother Watch	2025-12-10	Parliamentary Submission	Briefing on Data Use and Access Bill 2024	https://bigbrotherwatch.org.uk/press-releases/concerns-over-governments-new-data-bill/	DSIT; Parliament	\N	f	\N	f	Raised concerns that DUA Bill enabled automated fraud detection across DWP and HMRC data with insufficient safeguards. Called for amendments requiring human review of all automated decisions affecting benefits claimants and mandatory DPIAs for public sector AI tools.	Automated decision-making; welfare data; benefits processing; DPIA obligations	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Civil liberties campaign	\N	DUA Bill; ADM; welfare; DWP; HMRC; DPIA; human oversight; public sector AI	\N	Government	\N		0.75
M1-007	Open Rights Group	2026-04-02	Formal Complaint	ORG complaint to ICO about LiveRamp adtech data processing	https://www.openrightsgroup.org/press-releases/org-complaint-liveramp-adtech/	LiveRamp	\N	t	\N	f	Complaint to ICO and French CNIL against LiveRamp's RampID identity graph system. Found processing indiscriminately linked names and addresses with browsing histories for millions of UK users without adequate legal basis or transparency. Part of ongoing ORG campaign against unlawful adtech since 2018.	Behavioural advertising; data brokerage; profiling; consent; lawful basis	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	adtech; LiveRamp; RampID; consent; lawful basis; profiling; ICO complaint; CNIL; surveillance capitalism	\N	Private sector	\N	ICO acknowledged; outcome pending at April 2026	0.78
M1-008	Open Rights Group	2025-03-07	Formal Complaint	ORG complaint to ICO re Meta AI training on UK user data	https://www.openrightsgroup.org/publications/complaint-to-the-ico-about-meta/	Meta Platforms	\N	t	\N	f	Formal ICO complaint about Meta's use of Facebook and Instagram user data to train generative AI models without explicit consent. Argued no valid lawful basis; processing violated purpose limitation and data minimisation principles. ICO subsequently contacted Meta and Meta paused UK AI training.	Generative AI training; social media data; purpose limitation; consent; lawful basis	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	Meta; generative AI; AI training; lawful basis; purpose limitation; consent; ICO complaint; UK GDPR	\N	Private sector	\N	Meta paused UK AI training in June 2024 following ICO intervention. ORG met with ICO in late 2024.	0.9
M1-009	Open Rights Group	2025-02-11	Report	Alternative ICO Annual Report 2023-24	https://www.openrightsgroup.org/publications/ico-alternative-annual-report-2023-24/	Information Commissioner's Office	\N	f	\N	f	Critical assessment of ICO enforcement record. Found ICO issued only 4 private sector data protection fines in 2023-24. Compared unfavourably with European DPAs. Criticised two-year public sector trial for limiting fines. Called for statutory duty to publish enforcement logic; benchmarking against EU peers; mandatory priority sector lists.	ICO enforcement; data protection fines; public sector enforcement	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	ICO enforcement; alternative annual report; private sector fines; public sector trial; ORG; accountability	\N	Regulator	\N		0.82
M1-010	Open Rights Group	2024-05-03	Parliamentary Submission	Briefing on DPDI Bill HoL Committee Stage on ICO statutory duty	https://www.openrightsgroup.org/publications/briefing-the-ico-isnt-working/#:~:text=The%20Information%20Commissioner's%20Office%20(ICO)%20has%20a,of%20the%20Biometrics%20and%20Surveillance%20Camera%20Commissioner**	Parliament; DSIT	\N	f	\N	f	Amendment briefing for Lords Committee Stage. Proposed statutory requirement for ICO to publish assessment logic for all enforcement decisions including non-investigation decisions. Sought to remove secondary objectives framing innovation and growth as competing with data protection enforcement.	ICO enforcement; data subject rights; secondary objectives; ICO independence	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	DPDI Bill; ICO statutory duty; enforcement transparency; secondary objectives; ORG; Lords	\N	Government	\N		0.72
M1-011	Open Rights Group	2026-03-12	Parliamentary Submission	Joint briefing with BBW and Index on Censorship urging OSA reform or repeal	https://www.eff.org/deeplinks/2025/12/eff-open-rights-group-big-brother-watch-and-index-censorship-call-uk-government	Parliament; DSIT; Ofcom	\N	f	\N	f	Joint briefing to MPs ahead of parliamentary debate on petition to repeal the Online Safety Act signed by 550000+ people. Argued OSA threatens user privacy through algorithmic surveillance; restricts free expression; creates discrimination risk through age verification face checks; blocks millions without ID from internet access.	Online content moderation; age verification; biometric data; user profiling	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	Online Safety Act; OSA repeal; age verification; facial recognition; free expression; privacy; ORG; BBW	\N	Government	\N		0.72
M1-012	Privacy International	2025-01-06	Report	Research and advocacy on Palantir NHS data contracts	https://privacyinternational.org/sites/default/files/2021-11/All%20roads%20lead%20to%20Palantir%20with%20Palantir%20response%20v3.pdf	NHS England; DHSC; Palantir	\N	f	\N	f	Ongoing research mapping Palantir's connections with UK state including NHS Federated Data Platform contract. Raised data protection concerns about lack of transparency in contract terms; data subject rights; international transfers; lawful basis for sensitive health data processing by a US defence contractor.	Health data processing; international transfers; lawful basis; data subject rights; special category data	\N	\N	\N	2027-05-04 00:00:00+01	0.85	t	\N	\N	\N	Digital rights research	\N	Palantir; NHS; health data; international transfers; surveillance capitalism; ICO; data subject rights	\N	Public authority; Private sector	\N		0.78
M1-013	Privacy International	2025-05-04	Parliamentary Submission	Written evidence to Science and Technology Committee inquiry on AI governance	https://privacyinternational.org/long-read/5343/producing-real-change-key-highlights-our-2024-results	Parliament; DSIT	\N	f	\N	f	Submitted evidence on need for binding AI regulation with strong data protection integration. Argued pro-innovation AI white paper insufficient; called for mandatory DPIAs for all high-risk AI; transparency requirements for training data; extraterritorial enforcement for UK resident data.	AI processing; DPIA obligations; training data transparency; extraterritorial enforcement	\N	\N	\N	2027-05-04 00:00:00+01	0.85	t	\N	\N	\N	Digital rights research	\N	AI governance; DPIA; training data; extraterritorial; binding regulation; human rights; Privacy International	\N	Government	\N		0.75
M1-014	Foxglove	2024-07-10	Legal Challenge	Home Office visa streaming tool legal challenge (settled 2023)	https://www.ein.org.uk/news/jcwi-and-technology-campaign-group-foxglove-launch-legal-challenge-over-home-offices-use	Home Office	\N	f	\N	t	Foxglove and JCWI legal challenge against Home Office algorithmic visa streaming tool. Argued AI tool directing applications to fast/slow/full-scrutiny lanes was discriminatory and lacked transparency. Home Office ultimately scrapped the tool and acknowledged its unlawful operation.	Automated decision-making; immigration data processing; algorithmic discrimination; special category data	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Tech justice legal	\N	Home Office; visa algorithm; ADM; discrimination; immigration; algorithmic transparency; Foxglove; JCWI	\N	Public authority	\N	Home Office scrapped streaming tool; acknowledged issues. Settled 2023.	0.85
M1-015	Foxglove	2026-09-08	Legal Challenge	Foxglove and Global Action Plan legal challenge re hyperscale data centre approval	https://www.globalactionplan.org.uk/news/global-action-plan-and-foxglove-launch-legal-challenge-against-government-decision-to-force-construction-of-a-hyperscale-data-centre	MHCLG; Angela Rayner	\N	f	\N	t	Planning statutory review filed against Deputy Prime Minister's decision to approve 90MW hyperscale data centre at Iver without environmental impact assessment. Argued data centres' water and power consumption requires full EIA; government failed to assess impact on local infrastructure.	Data centre operations; environmental impact; AI infrastructure	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Tech justice legal	\N	data centres; hyperscale; AI infrastructure; planning; environmental; Foxglove; judicial review	\N	Government	\N	Filed August 2025; ongoing	0.55
M1-016	Foxglove	2024-01-10	Legal Challenge	GMCDP and Foxglove challenge to DWP fraud detection algorithm	https://gmcdp.com/gmcdp-foxglove-legal-challenge-department-work-and-pensions-dwp-fraud-algorithm	DWP	\N	f	\N	t	Judicial review challenge against DWP's use of automated fraud detection algorithms affecting disabled benefit claimants. Argued processing lacked lawful basis; violated rights under UK GDPR and Equality Act 2010; no meaningful human review of automated decisions adversely affecting claimants.	Automated decision-making; welfare data; algorithmic discrimination; disability data	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Tech justice legal	\N	DWP; fraud detection; ADM; disabled claimants; UK GDPR; Equality Act; judicial review; Foxglove	\N	Public authority	\N	Pre-action correspondence stage at April 2026	0.82
M1-017	Liberty	2024-11-05	Report	Liberty critique of facial recognition at Beyonce Cardiff concert and King's Coronation	https://www.bbc.co.uk/news/uk-wales-65622404	South Wales Police; Metropolitan Police	\N	f	\N	f	Published legal analysis criticising police use of LFR at major public events without adequate legal framework. Argued processing disproportionate; reinforced discriminatory policing; violated Art.8 ECHR privacy rights. Called for legislative framework before any further police LFR deployments.	Biometric data processing; facial recognition; public event surveillance; special category data	\N	\N	\N	2027-05-04 00:00:00+01	0.85	t	\N	\N	\N	Human rights legal	\N	Liberty; facial recognition; LFR; police; Cardiff; King's Coronation; Art.8 ECHR; proportionality	\N	Public authority	\N		0.78
M1-018	Liberty	2026-12-01	Parliamentary Submission	Liberty briefing on DUA Bill — ICO independence and secondary objectives	https://www.openrightsgroup.org/app/uploads/2025/02/BRIEFING-Data-Use-and-Access-Bill-HoC-Second-Reading.pdf	Parliament; DSIT	\N	f	\N	f	Briefing opposing DUA Bill amendment removing ICO's obligation to prioritise data protection over secondary innovation and growth objectives. Argued amendment creates structural conflict of interest and risks EU adequacy. Supported Lord Clement-Jones amendment HoL122.	ICO independence; EU adequacy; data protection principles	\N	\N	\N	2027-05-04 00:00:00+01	0.85	t	\N	\N	\N	Human rights legal	\N	DUA Bill; ICO independence; secondary objectives; EU adequacy; Liberty; Lord Clement-Jones; HoL122	\N	Government	\N		0.75
M1-019	Foxglove	2025-01-04	Report	Foxglove investigation into government closeness to US Big Tech AI companies	https://www.foxglove.org.uk/2025/05/22/government-wallet-inspected-big-tech/	DSIT; Cabinet Office; GDS	\N	f	\N	f	Investigation into relationships between UK government ministers and US Big Tech AI companies including Anthropic and OpenAI. Raised concerns about procurement decisions; lack of transparency in GOV.UK Chat supplier selection; adequacy of data protection assessments for government AI contracts.	AI procurement; government data; lawful basis; international transfers	\N	\N	\N	2027-05-04 00:00:00+01	0.85	t	\N	\N	\N	Tech justice legal	\N	Foxglove; Big Tech; government AI; Anthropic; OpenAI; procurement; transparency; GOV.UK Chat	\N	Government	\N		0.7
M1-020	Open Rights Group	2027-01-07	Report	ORG briefing on OSA age verification and privacy implications	ORG briefing on OSA age verification and privacy implications	Ofcom; ICO	\N	f	\N	f	Policy brief examining privacy risks of age assurance mechanisms required under Online Safety Act. Argued biometric age verification creates disproportionate processing of special category data; alternative methods such as device-based verification should be preferred. Submitted to Ofcom consultation.	Biometric data processing; age verification; special category data; children's data	\N	\N	\N	2027-05-04 00:00:00+01	0.9	t	\N	\N	\N	Digital rights campaign	\N	OSA; age verification; biometrics; children's data; Ofcom; ICO; privacy; ORG	\N	Regulator	\N		0.72
\.


--
-- Data for Name: m2_media_press; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.m2_media_press (press_id, publication_date, outlet, outlet_tier, headline, source_url, author, story_type, target_org, ico_mentioned, ico_action, content_summary, processing_activities, topic_relevance_score, enforcement_stance, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
M2-001	2023-04-04	TechCrunch	2	TikTok hit with £12.7M UK fine for misusing children's data	https://techcrunch.com/2023/04/04/tiktok-uk-gdpr-kids-data-fine/	Natasha Lomas	News	TikTok	t	t	ICO fines TikTok £12.7m for allowing up to 1.4 million UK children under 13 to use the platform without parental consent between 2018 and 2020. Fine reduced from £27m after ICO dropped special category data finding. Commissioner Edwards quoted directly.	Children's data processing; consent; age verification; transparency	0.92	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-002	2024-07-10	The Register	2	UK tribunal agrees with Clearview AI — Brit data regulator has no jurisdiction	https://www.theregister.com/2023/10/19/uk_tribunal_agrees_with_clearview/		News	Clearview AI; ICO	t	f	First-tier Tribunal rules ICO had no jurisdiction to fine Clearview AI £7.5m because its services were provided to foreign law enforcement. ICO announces intent to appeal. Article explains implications for extraterritorial reach of UK GDPR over overseas AI companies.	Biometric data; facial recognition; AI training; extraterritorial enforcement	0.95	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-003	2024-05-11	The Register	2	UK watchdog bites back after Clearview AI fine blocked	https://www.theregister.com/2023/11/17/ico_clearview_fine/		News	Clearview AI; ICO	t	t	ICO formally appeals FTT ruling. Commissioner Edwards states commercial enterprises profiting from UK biometric data cannot claim law enforcement exemptions. Sets up the 2025 Upper Tribunal hearing that would ultimately restore the fine.	Biometric data; facial recognition; web scraping; AI training; UK GDPR scope	0.95	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-004	2025-02-06	The Register	2	Meta hits pause on EU AI training plans under pressure	https://www.theregister.com/2024/06/14/meta_eu_privacy/		News	Meta; ICO	t	f	Meta pauses AI training on EU and UK Facebook and Instagram user data following ICO intervention. ICO executive director Stephen Almond quoted: in order to get the most out of generative AI it is crucial that the public can trust their privacy rights will be respected.	Generative AI training; social media data; lawful basis; legitimate interests	0.97	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-005	2025-04-07	The Register	2	UK watchdog gets complaint about Meta gobbling user data for AI	https://www.theregister.com/2024/07/16/campaign_group_complains_to_uk/		News	Meta; ICO; Open Rights Group	t	t	Open Rights Group files formal ICO complaint about Meta's use of UK user data for AI training. ORG argues ICO pause did not make processing ban legally binding. Article covers enforcement gap between UK and EU regulatory response.	Generative AI training; lawful basis; ICO complaint; social media data	0.95	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-006	2025-02-09	The Register	2	Meta back at it — harvesting Britons' public Facebook and Insta feeds for AI training	https://www.theregister.com/2024/09/14/uk_meta_ai_facebook/		News	Meta; ICO	t	f	Meta resumes UK AI training after reaching agreement with ICO including simpler opt-out and longer decision period. ICO confirms it will continue to monitor. Article raises questions about adequacy of legitimate interests basis and contrast with EU opt-in requirements.	Generative AI training; lawful basis; opt-out; social media data	0.9	Neutral	2027-05-04 00:00:00+01	0.9	t
M2-007	2024-07-08	The Register	2	ICO plans £6.09m fine for Advanced over 2022 NHS ransomware attack	https://www.theregister.com/2024/08/07/ico_plans_to_fine_nhs/		News	Advanced Computer Software; ICO; NHS	t	f	ICO provisional fine notice against Advanced for LockBit ransomware attack disrupting NHS 111. First major action against a data processor. 82946 people's data stolen including home access details for 890 vulnerable individuals receiving care at home.	Health data processing; cybersecurity; processor obligations; MFA	0.9	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-008	2027-03-03	The Register	2	ICO fines NHS software supplier £3m for ransomware failings	https://www.theregister.com/2025/03/27/ransomwared_nhs_software_supplier_nabs/		News	Advanced Computer Software; ICO; NHS	t	t	ICO finalises £3.07m fine against Advanced for 2022 LockBit attack — reduced from £6.09m after cooperation and remediation. Commissioner Edwards warns every external connection must be secured with MFA. First significant fine against a data processor in UK.	Health data processing; cybersecurity; processor obligations; MFA; NHS	0.9	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-009	2027-03-03	Computer Weekly	2	Advanced Software fined £3m over LockBit attack	https://www.computerweekly.com/news/366621298/Advanced-Software-fined-3m-over-LockBit-attack		News	Advanced Computer Software; ICO; NHS	t	f	Computer Weekly covers ICO fine against Advanced now trading as OneAdvanced. Focuses on NHS 111 Adastra clinical system disruption. Notes voluntary settlement and cooperation with NCSC and NCA. Quotes legal comment on implications for processor security obligations.	Health data processing; processor obligations; cybersecurity; NHS	0.88	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-010	2025-09-10	The Register	2	Clearview AI sees red as UK tribunal sides with data regulator	https://www.theregister.com/2025/10/09/ico_clearview_ai_tribunal/		News	Clearview AI; ICO	t	f	Upper Tribunal overturns 2023 FTT ruling. UT rules Clearview's processing was behaviour monitoring of UK residents per Article 3(2)(b) UK GDPR. Commercial entities selling to foreign governments cannot claim law enforcement exemption. Restores £7.5m fine. Landmark precedent for AI training data scraping cases.	Biometric data; facial recognition; web scraping; AI training; extraterritorial enforcement	0.97	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-011	2026-03-10	The Register	2	Capita fined £14m after 58-hour delay exposed 6.6m records	https://www.theregister.com/2025/10/15/ico_fines_capita_14m/		News	Capita; ICO	t	t	ICO fines Capita £14m for 2023 Black Basta ransomware breach affecting 6.6 million people across 325 organisations. Fine reduced from proposed £45m after voluntary settlement and remediation. ICO's largest ever settlement. 58-hour delay in quarantining compromised device cited as core failure.	Cybersecurity; data breach; processor obligations; special category data	0.92	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-012	2026-03-10	Computer Weekly	2	ICO fines Capita £14m after ransomware caused major data breach	https://www.computerweekly.com/news/366632591/ICO-fines-Capita-14m-after-ransomware-caused-major-data-breach		News	Capita; ICO	t	f	Computer Weekly covers £14m Capita fine. Fine reduced from £45m after mitigating factors including security improvements and victim support. Includes comment from Barings Law running class action on behalf of thousands of affected individuals.	Cybersecurity; data breach; processor obligations	0.9	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-013	2027-01-11	The Register	2	Calls grow for inquiry into UK data watchdog after MoD Afghan data leak	https://www.theregister.com/2025/11/25/ico_inquiry_afghan_mod/		News	ICO; Ministry of Defence	t	t	Civil society calls for parliamentary inquiry into ICO following criticism of reprimand-only response to MoD Afghan data breach. ORG calls for ICO to use full enforcement powers. Article covers ICO public sector approach trial; rising complaint volumes; 11% increase in reported breaches since enforcement pullback.	ICO enforcement; public sector data; ICO accountability	0.88	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-014	2027-12-02	The Register	2	ICO fines Reddit £14.47m for letting kids slip past the gate	https://www.theregister.com/2026/02/24/ico_fines_reddit/		News	Reddit; ICO	t	t	ICO fines Reddit £14.47m for failing to introduce age assurance until July 2025 despite known children using platform and no DPIA conducted before January 2025. Second major children's privacy fine within weeks of Imgur enforcement. ICO investigating 17 other platforms including Discord and Pinterest.	Children's data processing; age assurance; DPIA; online safety	0.93	Pro-enforcement	2027-05-04 00:00:00+01	0.9	t
M2-015	2023-04-04	BBC	1	TikTok fined �12.7m for misusing children's data	https://www.bbc.co.uk/news/uk-65175902	Shiona McCallum; Tom Gerken; Zoe Klienman	News	TikTok; ICO	t	t	ICO fines TikTok £12.7m for allowing up to 1.4 million UK children under 13 to use the platform without parental consent between 2018 and 2020. Fine reduced from £27m after ICO dropped special category data finding. Commissioner Edwards quoted directly.	Children's data processing; consent; age verification; transparency	0.92	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
M2-016	2023-04-04	The Guardian	1	TikTok fined �12.7m for illegally processing children�s data	https://www.theguardian.com/technology/2023/apr/04/tiktok-fined-uk-data-protection-law-breaches	Alex Hern; Aletha Adu	News	TikTok; ICO	t	t	ICO fines TikTok £12.7m for allowing up to 1.4 million UK children under 13 to use the platform without parental consent between 2018 and 2020. Fine reduced from £27m after ICO dropped special category data finding. Commissioner Edwards quoted directly.	Children's data processing; consent; age verification; transparency	0.92	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
M2-017	2024-06-10	BBC	1	Face search company Clearview AI overturns UK privacy fine	https://www.bbc.co.uk/news/technology-67133157	Chris Vallance	News	Clearview AI; ICO	t	f	A company which enables its clients to search a database of billions of images scraped from the internet for matches to a particular face has won an appeal against the UK's privacy watchdog.	Biometric data; facial recognition; web scraping; AI training; extraterritorial enforcement	0.97	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
M2-018	2021-03-10	BBC	1	Outsourcing firm Capita fined �14m after millions had data stolen	https://www.bbc.co.uk/news/articles/c9d6yxdq3d2o	Imran Rahman-Jones	News	Capita; ICO	t	t	ICO fines Capita £14m for 2023 Black Basta ransomware breach affecting 6.6 million people across 325 organisations. Fine reduced from proposed £45m after voluntary settlement and remediation. ICO's largest ever settlement. 58-hour delay in quarantining 	Cybersecurity; data breach; processor obligations	0.9	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
M2-019	2027-12-02	BBC	1	Reddit fined �14m for 'concerning' child age check failings	https://www.bbc.co.uk/news/articles/cwyx0xggepjo	Tome Singleton; Liv McMahon	News	Reddit; ICO	t	t	ICO fines Reddit £14.47m for failing to introduce age assurance until July 2025 despite known children using platform and no DPIA conducted before January 2025. Second major children's privacy fine within weeks of Imgur enforcement. ICO investigating 17 	Children's data processing; age assurance; DPIA; online safety	0.93	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
M2-020	2025-03-03	BBC	1	TikTok investigated over use of children's data	https://www.bbc.co.uk/news/articles/c62xxz141plo	Tom Gerken	News	TikTok; ICO	t	f	The UK data watchdog has launched what it calls a "major investigation" into TikTok's use of children's personal information.\n	Children's data processing; consent; age verification; transparency	0.93	Pro-enforcement	2027-09-04 00:00:00+01	0.9	t
\.


--
-- Data for Name: p1_government_speeches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p1_government_speeches (speech_id, title, speaker_name, speaker_role, party, department, speech_date, speech_url, rss_guid, topic_relevance_score, processing_activities, relevance_tag, priority_level, regulatory_stance, enforcement_signal, nlp_confidence, ico_mentioned, ingested_at, raw_text, manually_reviewed, topic_relevence_score) FROM stdin;
P1-001	A pro-innovation approach to AI regulation (White Paper)	Michelle Donelan	Secretary of State for Science Innovation and Technology	Conservative	DSIT	2025-05-03	https://www.gov.uk/government/publications/ai-regulation-a-pro-innovation-approach/white-paper	\N	\N	AI regulation; data protection principles in AI; automated decision-making; ICO role in AI oversight	AI regulation white paper; pro-innovation; five principles; ICO; sector-led; DSIT; AI safety; fairness; accountability	Primary	Neutral	0.55	0.9	t	2027-04-04 00:00:00+01	Government white paper setting out UK's proposed approach to AI regulation. Proposes five cross-sectoral principles (safety; transparency; fairness; accountability; contestability) to be interpreted by existing regulators including ICO within their remits. Explicitly rejects horizontal AI legislation in favour of sector-based approach. Asks regulators to publish AI strategies by April 2024. Announces over £100m for AI safety. ICO cited as key regulator for data protection aspects of AI.	t	0.95
P1-002	AI Safety Summit opening remarks — Bletchley Declaration	Rishi Sunak	Prime Minister	Conservative	Cabinet Office	2023-01-11	https://www.gov.uk/government/speeches/prime-minister-rishi-sunak-opening-remarks-at-ai-safety-summit	\N	\N	AI safety; frontier AI risk; international AI governance	AI Safety Summit; Bletchley; frontier AI; AI safety; international cooperation; AI Safety Institute	Secondary	Neutral	0.5	0.85	f	2027-04-04 00:00:00+01	Prime Minister opened the first global AI Safety Summit at Bletchley Park with 28 nations signing the Bletchley Declaration on AI safety. Declaration established shared understanding of frontier AI risks and commitment to share research on AI safety. Announced establishment of the AI Safety Institute. Framed as UK leading global AI safety agenda. Limited direct data protection or ICO content.	t	0.88
P1-003	Government response to AI regulation white paper consultation	Michelle Donelan	Secretary of State for Science Innovation and Technology	Conservative	DSIT	2024-06-02	https://www.gov.uk/government/consultations/ai-regulation-a-pro-innovation-approach-policy-proposals/outcome/a-pro-innovation-approach-to-ai-regulation-a-pro-innovation-approach	\N	\N	AI regulation; data protection in AI; ICO AI strategy; automated decision-making	AI regulation; white paper response; pro-innovation; ICO; sector-led; DSIT; AI Policy Directorate; AISI	Primary	Neutral	0.6	0.9	t	2027-04-04 00:00:00+01	Government's formal response to consultation on March 2023 AI white paper. Reaffirmed pro-innovation sector-led approach. Required key regulators including ICO to publish AI strategies by 30 April 2024. Announced AI Policy Directorate (growing to 160+ staff by end 2023). Confirmed AISI established. Signalled future legislation possible for AI harms where existing law inadequate. ICO explicitly named as lead regulator for data protection in AI.	t	0.92
P1-004	King's Speech 2024 — AI and technology commitments	Keir Starmer (Prime Minister) / King Charles III	Prime Minister	Labour	Cabinet Office	2025-05-07	https://www.gov.uk/government/speeches/the-kings-speech-2024	\N	\N	AI regulation; online safety; cyber security; digital government	King's Speech; AI Bill; AI regulation; Online Safety Act; Cyber Security and Resilience Bill; Labour government	Primary	Pro-enforcement	0.65	0.85	f	2027-04-04 00:00:00+01	First King's Speech under new Labour government. Committed to: (1) introduce AI legislation to place requirements on developers of the most powerful AI models; (2) implement Online Safety Act; (3) introduce Cyber Security and Resilience Bill. Technology Secretary Peter Kyle subsequently stated legislation on frontier AI would follow within a year. Signalled more interventionist approach to AI regulation than previous Conservative government.	t	0.9
P1-005	AI Opportunities Action Plan launch speech	Keir Starmer	Prime Minister	Labour	Cabinet Office	2026-01-01	https://www.gov.uk/government/speeches/pm-speech-on-ai-opportunities-action-plan-january-2025	\N	\N	AI in public services; AI infrastructure; data access for AI; AI governance	AI Opportunities Action Plan; AI growth zones; National Data Library; AI superpower; DSIT; Peter Kyle; pro-growth	Primary	Deregulatory	0.45	0.9	f	2027-04-04 00:00:00+01	Prime Minister launched AI Opportunities Action Plan at UCL setting out roadmap for AI to drive economic growth. Plan structured around three pillars: laying AI foundations; AI adoption in public sector; securing homegrown AI. Announced AI growth zones, National Data Library, new AI infrastructure investment. PM framing was explicitly pro-growth and dismissive of caution. Limited direct data protection or enforcement content but signals deregulatory political environment for AI.	t	0.92
P1-006	Technology Secretary speech at London Tech Week — frontier AI legislation	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2024-12-06	https://www.gov.uk/government/speeches/peter-kyle-speech-london-tech-week-2024	\N	\N	Frontier AI regulation; AI safety data; AI labs; AI governance	frontier AI; AI legislation; AI safety data; London Tech Week; Peter Kyle; Labour AI policy	Primary	Pro-enforcement	0.65	0.85	f	2027-04-04 00:00:00+01	Secretary of State for DSIT set out Labour's AI policy intentions at London Tech Week. Committed to legislating to require frontier AI labs to release safety data — framed as codifying the existing voluntary code into law. Indicated legislation would be more targeted than EU AI Act, focusing on high-risk systems. First major public commitment from new government on AI legislation.	t	0.9
P1-007	Data (Use and Access) Bill — second reading ministerial statement	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2024-06-11	https://www.gov.uk/government/speeches/data-use-and-access-bill-second-reading	\N	\N	Data protection reform; PECR reform; smart data; automated decision-making; ICO governance	DUAA; Data Use and Access Bill; data protection reform; PECR; smart data; ICO; Information Commission	Primary	Neutral	0.6	0.9	t	2027-04-04 00:00:00+01	Secretary of State introduced Data Use and Access Bill at Lords second reading. Framed bill as balancing data protection with enabling innovation and economic growth. Key measures highlighted: PECR fine uplift to UK GDPR levels; smart data schemes; digital identity framework; ADM reforms; ICO restructure to Information Commission. ICO governance changes explicitly discussed as improving regulatory effectiveness.	t	0.95
P1-008	AI and copyright consultation launch	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2025-05-12	https://www.gov.uk/government/consultations/ai-and-copyright	\N	\N	AI training data; copyright; web scraping; transparency for AI	AI copyright; creative industries; AI training data; transparency; consultation; DSIT	Secondary	Neutral	0.45	0.88	f	2027-04-04 00:00:00+01	DSIT launched consultation on AI and copyright seeking to clarify how copyright law applies to AI training data. Four policy options proposed balancing creator protection and AI innovation. Over 11,500 responses received. Closely related to ICO's generative AI consultation on lawful basis for web scraping. Signals government recognition that legal basis for AI training data is unresolved.	t	0.82
P1-009	AI Bill delay announcement — letter to MPs	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2025-06-06	https://www.gov.uk/government/publications/ai-bill-delay-letter-to-mps	\N	\N	Frontier AI regulation; AI safety; AI governance; AI copyright	AI Bill; AI regulation delay; frontier AI; copyright; parliamentary working group; DSIT; Peter Kyle	Primary	Neutral	0.5	0.88	f	2027-04-04 00:00:00+01	Secretary of State wrote to MPs announcing delay to UK AI Bill until summer 2026 at earliest. Stated government wished to align approach with US and ensure bill covers AI and copyright together. Committed to establishing Parliamentary Working Group on AI and copyright. Delay linked to protracted DUAA passage and difficulty separating AI regulation from copyright issues.	t	0.88
P1-010	AI Opportunities Action Plan — Peter Kyle press statement	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2026-01-01	https://www.gov.uk/government/news/ai-opportunities-action-plan	\N	\N	AI infrastructure; data access for AI; AI in public services; AI regulation	AI Opportunities Action Plan; DSIT; AI growth; National Data Library; AI growth zones; AI regulation; pro-innovation	Primary	Deregulatory	0.45	0.9	t	2027-04-04 00:00:00+01	Secretary of State Peter Kyle issued press statement launching AI Opportunities Action Plan. Framed plan as positioning UK as AI superpower. Announced National Data Library to improve data access for AI development — data protection implications flagged by critics. Committed regulators to publish annual reports on how they are enabling AI innovation. ICO among regulators expected to demonstrate pro-innovation approach.	t	0.9
P1-011	AI regulation white paper — Michelle Donelan press conference remarks	Michelle Donelan	Secretary of State for Science Innovation and Technology	Conservative	DSIT	2025-05-03	https://www.gov.uk/government/news/ai-white-paper-press-conference	\N	\N	AI regulation; ICO role; data protection in AI; sector-led regulation	AI white paper; pro-innovation; ICO; Michelle Donelan; DSIT; sector-led; AI safety; principles	Primary	Neutral	0.55	0.88	t	2027-04-04 00:00:00+01	Secretary of State press conference accompanying AI white paper. Donelan described UK approach as agile and sector-specific allowing UK to grip risks while enabling innovation. Explicitly referenced ICO as key player in data protection aspects of AI regulation. Framed as UK alternative to EU's prescriptive AI Act approach.	t	0.9
P1-012	Home Office press release — Online Safety Act commencement and illegal content duties	Yvette Cooper	Home Secretary	Labour	Home Office	2026-05-03	https://www.gov.uk/government/news/online-safety-act-illegal-content-duties-in-force	\N	\N	Online safety; illegal content; children's data protection; platform obligations	Online Safety Act; illegal content duties; Ofcom enforcement; children's safety; Home Office; Yvette Cooper	Secondary	Pro-enforcement	0.65	0.85	f	2027-04-04 00:00:00+01	Home Secretary press release marking Online Safety Act illegal content duties coming into force. Committed government to using full force of the Act to protect children and adults online. Flagged Ofcom's new enforcement powers and ICO coordination on children's data protection. Called on platforms to take responsibilities seriously or face regulatory consequences.	t	0.82
P1-013	DSIT press release — UK AI Safety Institute expanded to AI Security Institute	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2025-01-02	https://www.gov.uk/government/news/ai-safety-institute-becomes-ai-security-institute	\N	\N	AI safety; frontier AI evaluation; AI security; AI governance	AISI; AI Security Institute; AI safety; frontier AI; evaluation; DSIT; Peter Kyle; AI governance	Secondary	Pro-enforcement	0.55	0.88	f	2027-04-04 00:00:00+01	DSIT announced renaming and expansion of the AI Safety Institute to the AI Security Institute reflecting broader remit covering both safety and security threats from advanced AI. Expansion of mandate signals increased regulatory attention to AI capabilities. ICO cooperation with AISI on data protection aspects of frontier AI evaluation noted in broader policy context.	t	0.85
P1-014	AI and copyright — Secretary of State assurances during DUAA passage	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2026-02-05	https://www.gov.uk/government/speeches/ai-copyright-assurances-duaa	\N	\N	AI training data; copyright; data protection for creative works; web scraping	AI copyright; DUAA; assurances; transparency; Baroness Kidron; creative industries; AI training data	Secondary	Neutral	0.45	0.85	f	2027-04-04 00:00:00+01	Secretary of State gave assurances on AI and copyright during DUAA ping pong to enable bill to pass. Committed to Secretary of State reporting requirements on AI copyright impact (now in DUAA s.138 area). Established basis for Parliamentary Working Group. Assurances allowed Lords AI copyright amendments to be withdrawn enabling Royal Assent.	t	0.82
P1-015	DSIT press release — AI Growth Lab consultation launch	Peter Kyle	Secretary of State for Science Innovation and Technology	Labour	DSIT	2026-09-10	https://www.gov.uk/government/consultations/ai-growth-lab	\N	\N	AI regulation sandboxing; AI innovation; regulatory reform for AI; data protection in AI sandbox	AI Growth Lab; regulatory sandbox; DSIT; pro-growth; AI regulation; derogation; innovation	Primary	Deregulatory	0.4	0.88	f	2027-04-04 00:00:00+01	DSIT launched consultation on UK AI Growth Lab — a proposed sandbox allowing AI companies to test innovations under targeted regulatory modifications including potential derogations from data protection requirements. Red lines include consumer protection and fundamental rights. ICO and other DRCF regulators involved in design. Signals government intent to create more permissive regulatory environment for AI experimentation. Consultation closed January 2026.	t	0.88
\.


--
-- Data for Name: p2_party_manifestos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p2_party_manifestos (manifesto_id, party, election_year, commitment_text, processing_activities, topic_tags, obligation_direction, priority_level, governing_party, manifesto_project_id, source_url, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
P2-001	Labour	2019	We will ensure data protection for NHS and patient information, a highly valuable publicly funded resource that can be used for better diagnosis of conditions and saving lives, while maintaining strict privacy protections.	Health data processing; research data sharing; NHS data governance	health data; NHS; data protection; privacy; research; data sharing	Increases	Secondary	f	51320_201912	https://labour.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-002	Labour	2019	We will ensure NHS data is not exploited by international technology and pharmaceutical corporations.	Health data processing; commercial data use; NHS data governance	NHS data; tech companies; data exploitation; commercial use; data protection	Increases	Secondary	f	51320_201912	https://labour.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-003	Labour	2019	Ending the six-month time limit in which the Information Commissioner can prosecute the deliberate destruction of public records.	Records management; data destruction; ICO prosecution powers	ICO; Information Commissioner; prosecution; records destruction; enforcement	Increases	Secondary	f	51320_201912	https://labour.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-004	Labour	2019	We will take action to address the monopolistic hold the tech giants have on advertising revenues.	Behavioural advertising; data brokerage; platform data use	tech giants; advertising; monopoly; digital markets; data	Increases	Secondary	f	51320_201912	https://labour.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-005	Liberal Democrats	2019	Our ambition is for the UK to lead the world in ethical, inclusive new technology, including artificial intelligence.	AI processing; algorithmic systems; ethical AI	AI; ethics; technology; leadership; inclusive AI	Clarifies	Secondary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-006	Liberal Democrats	2019	Introducing a Lovelace Code of Ethics to ensure the use of personal data and AI is unbiased, transparent and accurate, and to protect individuals' rights with respect to automated decision-making.	Automated decision-making; personal data processing; AI systems	AI ethics; Lovelace Code; personal data; automated decision-making; transparency; bias	Increases	Primary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-007	Liberal Democrats	2019	Immediately halt the use of facial recognition surveillance by the police.	Biometric data processing; facial recognition; police surveillance	facial recognition; biometrics; police; surveillance; halt	Increases	Primary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-008	Liberal Democrats	2019	Make algorithms used by the data companies available for close inspection by regulators acting for democratically elected governments.	Algorithmic processing; platform data use; automated systems	algorithmic transparency; regulators; data companies; inspection; accountability	Increases	Secondary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-009	Liberal Democrats	2019	Convening a citizens' assembly to determine when it is appropriate for the government to use algorithms in decision-making.	Government automated decision-making; algorithmic systems	algorithmic decision-making; government; citizens assembly; accountability; ADM	Clarifies	Secondary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-010	Liberal Democrats	2019	Repeal the immigration exemption in the Data Protection Act.	Immigration data processing; DPA 2018 exemptions; data subject rights	immigration exemption; DPA 2018; data protection; repeal; data subject rights	Increases	Secondary	f	51421_201912	https://www.libdems.org.uk/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-011	Conservative	2019	End the sale of personal data, such as health or tax records, for commercial or other ends.	Health data processing; commercial data sale; public sector data	personal data sale; health data; commercial use; data protection	Increases	Secondary	f	51110_201912	https://www.conservatives.com/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-012	Conservative	2019	Introduce a regulatory framework for online harms to ensure social media companies take responsibility for how their platforms are being used.	Platform data processing; online content moderation; user data	online harms; social media; regulatory framework; platform responsibility; Online Safety Act precursor	Increases	Primary	f	51110_201912	https://www.conservatives.com/manifesto/2019	2026-04-16 00:00:00+01	1	t
P2-013	Labour	2024	Labour will ensure the safe development and use of AI models by introducing binding regulation on the handful of companies developing the most powerful AI models.	AI model development; frontier AI processing; AI governance	AI regulation; binding regulation; frontier AI; AI safety; Labour policy	Increases	Primary	t	51320_202407	https://labour.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-014	Labour	2024	We will create a National Data Library to bring together existing research programmes and help deliver data-driven public services, while maintaining strong safeguards and making sure all use of data has the potential to deliver benefits for the UK.	Research data processing; public sector data sharing; data governance	National Data Library; data sharing; public services; research; data-driven; safeguards	Mixed	Primary	t	51320_202407	https://labour.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-015	Labour	2024	Labour will build on the Online Safety Act, bringing forward provisions as quickly as possible.	Platform data processing; online safety; children's data	Online Safety Act; implementation; children's safety; platform obligations	Increases	Primary	t	51320_202407	https://labour.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-016	Labour	2024	We will ensure our industrial strategy supports the development of the Artificial Intelligence (AI) sector, removes planning barriers to new datacentres, and makes the UK the best place to start and grow an AI company.	AI data processing; datacentre infrastructure; AI development	AI sector; industrial strategy; datacentres; AI company; growth; pro-innovation	Decreases	Secondary	t	51320_202407	https://labour.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-017	Liberal Democrats	2024	Create a clear, workable and well-resourced cross-sectoral regulatory framework for artificial intelligence that: promotes innovation while creating certainty for businesses; establishes transparency and accountability for AI systems in the public sector; ensures the use of personal data and AI is unbiased, transparent and accurate, and respects the privacy of innocent people.	AI processing; automated decision-making; personal data in AI; public sector AI	AI regulatory framework; cross-sectoral; transparency; accountability; bias; privacy; Lib Dems	Increases	Primary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-018	Liberal Democrats	2024	Immediately halt the use of live facial recognition surveillance by the police and private companies.	Biometric data processing; facial recognition; live surveillance	facial recognition; live surveillance; police; private companies; halt; biometrics	Increases	Primary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-019	Liberal Democrats	2024	Introducing a legally binding regulatory framework for all forms of biometric surveillance.	Biometric data processing; surveillance; facial recognition; fingerprinting	biometric surveillance; binding framework; regulation; facial recognition; biometrics	Increases	Primary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-020	Liberal Democrats	2024	Introducing a Digital Bill of Rights to protect everyone's rights online, including the rights to privacy, free expression, and participation without discrimination.	Online data processing; digital rights; privacy; profiling	Digital Bill of Rights; online rights; privacy; discrimination; digital rights	Increases	Primary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-021	Liberal Democrats	2024	Repeal the immigration exemption in the Data Protection Act.	Immigration data processing; DPA 2018 exemptions; data subject rights	immigration exemption; DPA 2018; data protection; repeal; data subject rights	Increases	Secondary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-022	Liberal Democrats	2024	Increasing the Digital Services Tax on social media firms and other tech giants from 2% to 6%.	Platform data processing; digital advertising; tech giant taxation	Digital Services Tax; social media; tech giants; tax; DST	Increases	Secondary	f	51421_202407	https://www.libdems.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-023	Conservative	2024	The Digital Bill of Rights will give the public greater control over their data, ensuring UK data protection is as strong as any other regulatory regime in the world.	Personal data processing; data subject rights; data portability	Digital Bill of Rights; data protection; data control; UK GDPR; rights	Increases	Primary	f	51110_202407	https://www.conservatives.com/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-024	Conservative	2024	The rise of AI is transforming many industries and has enormous potential for good, when well regulated.	AI processing; automated systems; AI governance	AI regulation; well-regulated AI; pro-innovation; Conservative AI policy	Clarifies	Secondary	f	51110_202407	https://www.conservatives.com/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-025	Conservative	2024	We will legislate to create new offences for spiking, the creation of sexualised deepfake images and taking intimate images without consent.	Deepfake image processing; intimate images; AI-generated content	deepfakes; intimate images; non-consensual; NCII; AI-generated; new offence	Increases	Primary	f	51110_202407	https://www.conservatives.com/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-026	Conservative	2024	Gig employers that repeatedly breach data protection, employment or tax law will be denied licences to operate.	Employment data processing; data protection compliance; gig economy	data protection breach; gig economy; licence denial; enforcement; employment	Increases	Secondary	f	51110_202407	https://www.conservatives.com/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-027	Green	2024	We expect to build on the existing responsibilities set out for social media companies under the Online Safety Act.	Platform data processing; online safety; children's data; content moderation	Online Safety Act; social media; platform obligations; children; Green Party	Increases	Secondary	f	51620_202407	https://www.greenparty.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-028	Green	2024	We will legislate to create new offences for spiking, the creation of sexualised deepfake images and taking intimate images without consent.	Deepfake image processing; intimate images; AI-generated content	deepfakes; NCII; intimate images; AI-generated; criminal offence; Green Party	Increases	Primary	f	51620_202407	https://www.greenparty.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-029	Green	2024	Back the police, by giving officers new powers and tools to catch criminals, including technology like facial recognition.	Biometric data processing; facial recognition; police surveillance	facial recognition; police; technology; criminal justice; Green Party	Increases	Secondary	f	51620_202407	https://www.greenparty.org.uk/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-030	SNP	2024	Our data and privacy must be protected. Surveillance of the public must be limited and those monitoring us held to account.	Personal data processing; public surveillance; data subject rights	privacy; surveillance; data protection; accountability; SNP	Increases	Primary	f	51701_202407	https://www.snp.org/manifesto/2024	2026-04-16 00:00:00+01	1	t
P2-031	SNP	2024	Review the Online Safety Act.	Platform data processing; online safety; regulatory review	Online Safety Act; review; SNP; online safety	Clarifies	Secondary	f	51701_202407	https://www.snp.org/manifesto/2024	2026-04-16 00:00:00+01	1	t
\.


--
-- Data for Name: p3_budget_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p3_budget_documents (budget_id, budget_year, budget_date, item_type, item_description, amount_gbp, yoy_change_pct, yoy_direction, ico_budget_flag, enforcement_signal, source_url, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
P3-001	2023	2024-03-03	ICO Allocation	ICO core resource budget from data protection fee income (FY 2022-23). Primary funding source for ICO regulatory operations including enforcement investigations and litigation.	66000000.00	6.45	Increase	t	0.7	https://ico.org.uk/about-the-ico/who-we-are/how-we-are-funded/	2027-04-04 00:00:00+01	1	t
P3-002	2023	2024-03-03	ICO grant-in-aid	Grant-in-aid from government to fund ICO's regulation of non-data protection legislation including FOIA and EIR (FY 2022-23).	10298000.00	35.9	Increase	t	0.55	https://ico.org.uk/about-the-ico/who-we-are/how-we-are-funded/	2027-04-04 00:00:00+01	1	t
P3-003	2023	2024-03-03	AI regulation investment	Government investment in AI safety and regulation infrastructure. £100m announced to help regulators including ICO build technical AI capabilities (white paper response commitment).	100000000.00	\N	New Item	f	0.65	https://www.gov.uk/government/publications/ai-regulation-a-pro-innovation-approach/white-paper	2027-04-04 00:00:00+01	1	t
P3-004	2023	2024-03-03	AI Safety Institute establishment	Budget allocation to establish the AI Safety Institute (AISI) — initial seed funding to evaluate frontier AI models and build AI safety research capability.	\N	\N	New Item	f	0.55	https://www.gov.uk/government/news/uk-to-launch-ai-safety-institute	2027-04-04 00:00:00+01	1	t
P3-005	2024	2024-06-03	DSIT total DEL budget (Spring Budget 2024)	Total DSIT Departmental Expenditure Limit for 2024-25 following Spring Budget. Includes R&D investment; AI Safety Institute; digital infrastructure. 6.5% average growth rate from 2023-24.	12700000000.00	6.5	Increase	f	0.55	https://www.gov.uk/government/publications/spring-budget-2024	2027-04-04 00:00:00+01	1	t
P3-006	2024	2024-06-03	AI upskilling fund — SMEs	New £7.4 million AI upskilling fund pilot to help SMEs develop AI skills and adopt AI technologies (Spring Budget 2024).	7400000.00	\N	New Item	f	0.45	https://www.gov.uk/government/publications/spring-budget-2024	2027-04-04 00:00:00+01	1	t
P3-007	2024	2024-06-03	Alan Turing Institute — AI investment	£100 million additional investment in the Alan Turing Institute over five years for AI research in healthcare; environment; defence. Doubled previous commitment.	100000000.00	\N	Increase	f	0.5	https://www.gov.uk/government/publications/spring-budget-2024	2027-04-04 00:00:00+01	1	t
P3-008	2024	2024-06-03	AISI budget increase	£6.5 million increase in AI Safety Institute contributions from multiple departments to support frontier AI safety evaluation capability.	6500000.00	\N	Increase	f	0.55	https://www.gov.uk/government/publications/dsit-main-estimate-memorandum-2024-to-2025/dsit-main-estimate-memorandum-2024-to-2025	2027-04-04 00:00:00+01	1	t
P3-009	2024	2026-06-10	DSIT total DEL budget (Autumn Budget 2024)	Total DSIT DEL budget for 2025-26 confirmed at Autumn Budget 2024 — £15.1bn including £13.9bn R&D. Represents 6.5% average growth rate from 2023-24.	15100000000.00	18.9	Increase	f	0.55	https://www.gov.uk/government/publications/autumn-budget-2024	2027-04-04 00:00:00+01	1	t
P3-010	2024	2026-06-10	ICO Allocation	ICO core resource budget from data protection fee income (FY 2024-25 estimated). Continued growth in fee income reflecting growth in registered data controllers.	70000000.00	6.06	Increase	t	0.7	https://ico.org.uk/about-the-ico/who-we-are/how-we-are-funded/	2027-04-04 00:00:00+01	1	t
P3-011	2024	2026-06-10	ICO enforcement cost retention	HM Treasury continued authorisation for ICO to retain specified amounts from Civil Monetary Penalties to cover pre-agreed enforcement and litigation costs. Cap of £7.5m per financial year.	7500000.00	0	Flat	t	0.8	https://ico.org.uk/about-the-ico/our-information/annual-reports/	2027-04-04 00:00:00+01	1	t
P3-012	2024	2026-06-10	DSIT digital transformation — shared services	£80 million DSIT investment to transform corporate functions across nine government departments as part of Shared Services Strategy. Includes AI and digital tooling.	80000000.00	\N	New Item	f	0.45	https://www.gov.uk/government/publications/autumn-budget-2024	2027-04-04 00:00:00+01	1	t
P3-013	2024	2026-06-10	AI chips — advanced market commitment	Up to £100 million government advanced market commitment to act as early buyer for next-generation AI chips from UK startups. Subject to due diligence.	100000000.00	\N	New Item	f	0.45	https://www.gov.uk/government/news/budget-backs-technology-firms-to-start-up-scale-up-and-stay-in-britain-to-drive-growth-and-national-renewal	2027-04-04 00:00:00+01	1	t
P3-014	2024	2026-06-10	Innovate UK Growth Catalyst — AI and tech	New £130 million Innovate UK Growth Catalyst scheme offering grants and tailored support for companies at the frontier of science and technology including AI.	130000000.00	\N	New Item	f	0.45	https://www.gov.uk/government/publications/autumn-budget-2024	2027-04-04 00:00:00+01	1	t
P3-015	2025	2025-11-06	DSIT R&D budget 2025-26	Total DSIT R&D budget for 2025-26 confirmed at £13.9bn. Part of £20.4bn overall government R&D investment. Includes UKRI (£8.8bn); Horizon Europe; AISI (£66m); ARIA (£184m).	13900000000.00	9.45	Increase	f	0.55	https://www.gov.uk/government/publications/dsit-research-and-development-rd-allocations-for-20252026	2027-04-04 00:00:00+01	1	t
P3-016	2025	2025-11-06	AISI (AI Security Institute) budget 2025-26	Confirmed £66 million investment in AISI (renamed AI Security Institute) for 2025-26 to evaluate frontier AI models and equip governments with scientific understanding of advanced AI risks.	66000000.00	914.29	Increase	f	0.65	https://www.gov.uk/government/publications/dsit-research-and-development-rd-allocations-for-20252026	2027-04-04 00:00:00+01	1	t
P3-017	2025	2025-11-06	UKRI AI sector investment 2026-2030	UKRI committed record £1.6 billion over four years (2026-2030) directly targeted at AI sector — largest single UKRI investment area. Includes AI for Science strategy (£137m); DAWN supercomputer upgrade (£36m).	1600000000.00	\N	New Item	f	0.5	https://www.gov.uk/government/news/bold-bet-on-ai-to-keep-uk-at-forefront-of-science-and-research-breakthroughs	2027-04-04 00:00:00+01	1	t
P3-018	2025	2027-02-11	Sovereign AI Unit — DSIT	£500 million Sovereign AI Unit established within DSIT to invest in UK AI national champions; create UK AI assets (data; compute; talent); make UK partner of choice for frontier AI companies.	500000000.00	\N	New Item	f	0.5	https://www.gov.uk/government/news/new-package-puts-ai-at-the-heart-of-national-renewal-package	2027-04-04 00:00:00+01	1	t
P3-019	2025	2027-02-11	AI Growth Zones — infrastructure investment	Dedicated AI Growth Zones (AIGZs) receiving £5m government commitment each to work with local authorities on AI adoption and skills. Expected to unlock £10bn private investment. Locations: Wales (x2); North East England; Oxfordshire.	5000000.00	\N	New Item	f	0.4	https://www.gov.uk/government/news/new-package-puts-ai-at-the-heart-of-national-renewal-package	2027-04-04 00:00:00+01	1	t
P3-020	2025	2027-02-11	PECR fee income — anticipated uplift	Anticipated increase in ICO fee income from PECR enforcement following DUAA 2025 uplift of maximum PECR fine from £500k to £17.5m/4% global turnover. No specific budget line but material enforcement revenue change.	\N	\N	Increase	t	0.85	https://www.gov.uk/guidance/data-use-and-access-act-2025-data-protection-and-privacy-changes	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: p4_electoral_signals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p4_electoral_signals (electoral_id, record_date, last_election_date, next_election_due, governing_party, governing_poll_ptc, opposition_poll_ptc, poll_source, prediction_market_prob, gov_change_12m, ingested_at, labour_poll_ptc, conservative_poll_ptc, libdem_poll_ptc, reform_poll_ptc, green_poll_ptc) FROM stdin;
P4-001	2023-01-01	2019-12-12	2027-04-01	Conservative	25	47	YouGov / Savanta aggregate (Jan 2023)	0.03	0.82	2027-05-04 00:00:00+01	47	25	9	5	4
P4-002	2023-01-04	2019-12-12	2027-04-01	Conservative	26	47	YouGov / Ipsos aggregate (Apr 2023)	0.04	0.8	2027-05-04 00:00:00+01	47	26	9	6	5
P4-003	2023-01-07	2019-12-12	2027-04-01	Conservative	26	44	YouGov / Savanta aggregate (Jul 2023)	0.04	0.81	2027-05-04 00:00:00+01	44	26	9	7	6
P4-004	2023-01-10	2019-12-12	2027-04-01	Conservative	25	45	YouGov / Opinium aggregate (Oct 2023)	0.03	0.83	2027-05-04 00:00:00+01	45	25	9	8	6
P4-005	2024-01-01	2019-12-12	2027-04-01	Conservative	24	44	YouGov / Savanta aggregate (Jan 2024)	0.04	0.84	2027-05-04 00:00:00+01	44	24	9	11	6
P4-006	2024-01-04	2019-12-12	2027-04-01	Conservative	24	43	YouGov / Savanta / Deltapoll aggregate (Apr 2024)	0.04	0.84	2027-05-04 00:00:00+01	43	24	9	11	7
P4-007	2024-04-07	2019-12-12	2024-04-07	Conservative	23.7	33.7	2024 General Election result (actual vote shares)	0.01	1	2027-05-04 00:00:00+01	33.7	23.7	12.2	14.3	6.7
P4-008	2024-01-10	2024-04-07	2030-03-08	Labour	27	22	YouGov / Opinium aggregate (Oct 2024)	0.75	0.08	2027-05-04 00:00:00+01	27	22	11	20	8
P4-009	2025-01-01	2024-04-07	2030-03-08	Labour	24	23	YouGov aggregate (Jan 2025)	0.65	0.14	2027-05-04 00:00:00+01	24	20	11	23	9
P4-010	2025-01-04	2024-04-07	2030-03-08	Labour	24	25	YouGov / Electoral Calculus aggregate (Apr 2025)	0.55	0.22	2027-05-04 00:00:00+01	24	18	11	25	10
P4-011	2025-01-07	2024-04-07	2030-03-08	Labour	22	29	Electoral Calculus MRP (Jul 2025)	0.45	0.3	2027-05-04 00:00:00+01	22	17	11	29	12
P4-012	2025-01-10	2024-04-07	2030-03-08	Labour	21	36	Electoral Calculus MRP October 2025 (Find Out Now; n=7449)	0.35	0.42	2027-05-04 00:00:00+01	21	15	10	36	13
P4-013	2026-01-01	2024-04-07	2030-03-08	Labour	19	26	YouGov / PolitPro aggregate (Jan 2026)	0.38	0.38	2027-05-04 00:00:00+01	19	18	11	26	14
P4-014	2026-01-04	2024-04-07	2030-03-08	Labour	18	25.9	PolitPro / Electoral Reform Society aggregate (Mar-Apr 2026)	0.4	0.36	2027-05-04 00:00:00+01	18	18.6	11.7	25.9	16.7
\.


--
-- Data for Name: p5_social_listening; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p5_social_listening (social_id, platform, account_handle, account_name, account_category, party, party_power, post_date, post_id_platform, raw_text, processing_activities, topic_relevance_score, topic_tags, priority_level, regulatory_stance, engagement_score, ingested_at, nlp_confidence, manually_reviewed, topic_relevence_score) FROM stdin;
P5-001	X/Twitter	@ICOnews	ICO - Information Commissioner's Office	Regulator	N/A	f	2023-06-12 00:00:00+01	\N	ICO Commissioner: 2024 cannot be the year consumers lose trust in AI. Organisations must use AI authentically and transparently. We issued a preliminary enforcement notice against Snap over their My AI chatbot — their failure to properly assess data protection risks is not acceptable. If you use AI you must be able to demonstrate you have protected people's information.	AI data processing; generative AI risk; DPIA obligations	\N	AI trust; generative AI; ICO enforcement; Snap; DPIA; My AI	Primary	Pro-enforcement	4200	2027-05-04 00:00:00+01	0.85	t	0.95
P5-002	X/Twitter	@ICOnews	ICO - Information Commissioner's Office	Regulator	N/A	f	2025-11-02 00:00:00+00	\N	ICO has ordered Serco Leisure to stop using facial recognition and fingerprint scanning to monitor staff attendance. Biometric data is wholly unique — you can't reset someone's face like a password. This action puts industry on notice: biometric technologies cannot be deployed lightly.	Biometric data processing; facial recognition; employment	\N	biometrics; facial recognition; Serco; enforcement; workplace surveillance; special category data	Primary	Pro-enforcement	8900	2027-05-04 00:00:00+01	0.85	t	0.95
P5-003	X/Twitter	@ICOnews	ICO - Information Commissioner's Office	Regulator	N/A	f	2024-01-06 00:00:00+00	\N	ICO is pleased Meta paused its plans to train AI on UK users' Facebook and Instagram data following our concerns. To get the most from AI it is crucial the public can trust their privacy rights will be respected from the outset. We will continue to monitor major generative AI developers.	Generative AI training; social media data; lawful basis	\N	Meta; AI training; generative AI; lawful basis; UK GDPR; privacy rights	Primary	Pro-enforcement	11200	2027-05-04 00:00:00+01	0.85	t	0.98
P5-004	X/Twitter	@ICOnews	ICO - Information Commissioner's Office	Regulator	N/A	f	2026-04-02 00:00:00+01	\N	Our bots are coming for your bots. We are developing automated tools to identify websites with non-compliant cookie banners. We reviewed the top 100 UK websites — 53 had potentially non-compliant banners. Our message is clear: it must be just as easy to reject cookies as to accept them.	Cookie processing; consent management; behavioural advertising	\N	cookies; consent; cookie banners; compliance; ICO enforcement; PECR; ad-tech	Primary	Pro-enforcement	6800	2027-05-04 00:00:00+01	0.85	t	0.9
P5-005	X/Twitter	@ICOnews	ICO - Information Commissioner's Office	Regulator	N/A	f	2025-05-06 00:00:00+01	\N	The same data protection principles apply as they always have — trust matters and can only be built by organisations using people's personal information responsibly. AI is more than just a technology change; it is a change in society. AI must work for everyone not just a few.	AI processing; data protection principles; AI governance	\N	AI; data protection principles; trust; ICO; AI strategy; biometrics	Primary	Pro-enforcement	5300	2027-05-04 00:00:00+01	0.85	t	0.92
P5-006	X/Twitter	@PeterKyleMP	Peter Kyle MP	Minister	Labour	t	2024-12-06 00:00:00+00	\N	At London Tech Week: under Labour we would legislate to require frontier AI labs to release their safety data. We need to move the voluntary code to a statutory regime — not a bureaucratic AI Act but targeted legislation so government can understand the risks AI poses.	Frontier AI processing; AI safety evaluation; AI governance	\N	frontier AI; AI legislation; AI safety data; Labour; DSIT; pro-enforcement	Primary	Pro-enforcement	9400	2027-05-04 00:00:00+01	0.85	t	0.92
P5-007	X/Twitter	@PeterKyleMP	Peter Kyle MP	Minister	Labour	t	2026-01-01 00:00:00+00	\N	Today we launch the AI Opportunities Action Plan — 50 recommendations to make the UK the best place to start grow and scale an AI company. National Data Library. AI Growth Zones. £14 billion committed by tech firms. There is no time to waste. The future is being built now.	AI infrastructure; national data; AI investment; public sector AI	\N	AI Action Plan; National Data Library; AI Growth Zones; pro-growth; Labour	Primary	Deregulatory	18700	2027-05-04 00:00:00+01	0.85	t	0.88
P5-008	X/Twitter	@PeterKyleMP	Peter Kyle MP	Minister	Labour	t	2025-06-06 00:00:00+01	\N	I have written to MPs explaining that we are delaying the AI Bill until 2026. We want to get this right — aligning with the US and ensuring we tackle AI and copyright together. I am establishing a Parliamentary Working Group on AI and copyright.	Frontier AI regulation; AI copyright; AI governance	\N	AI Bill; delay; AI regulation; copyright; Peter Kyle; 2026; DSIT	Primary	Neutral	7200	2027-05-04 00:00:00+01	0.85	t	0.88
P5-009	X/Twitter	@MichelleDonelan	Michelle Donelan MP	Shadow Minister	Conservative	f	2025-05-03 00:00:00+01	\N	I have sought to double down on our pro-innovation approach to AI. Britain will be the safest and most innovative place to develop and deploy AI in the world. Our sector-led framework allows us to move at the pace of AI itself — not be slowed down by prescriptive legislation.	AI regulation; AI governance; sector-led regulation	\N	AI regulation white paper; pro-innovation; DSIT; sector-led; ICO; Conservative	Primary	Neutral	8100	2027-05-04 00:00:00+01	0.85	t	0.9
P5-010	X/Twitter	@VisCountCamrose	Viscount Camrose	Shadow Minister	Conservative	f	2024-06-02 00:00:00+01	\N	The government believes our approach — combining a principles-based framework international leadership and voluntary measures on developers — is right for today. We asked regulators including the ICO to publish their AI strategies by 30 April 2024.	AI regulation; ICO AI strategy; sector-led	\N	AI regulation; ICO strategy; Viscount Camrose; Conservative; DSIT Lords; April 2024	Secondary	Neutral	1800	2027-05-04 00:00:00+01	0.8	t	0.88
P5-011	X/Twitter	@Keir_Starmer	Keir Starmer	Party Leader	Labour	t	2026-01-01 00:00:00+00	\N	Artificial intelligence will deliver a decade of national renewal. For too long blockers have controlled public discourse and got in the way of growth. We are throwing the full weight of Whitehall behind AI. This is not the time for caution — it is the time to be bold.	AI infrastructure; public sector AI; AI governance	\N	AI Action Plan; pro-growth; Labour; Starmer; National Data Library; AI superpower	Secondary	Deregulatory	42000	2027-05-04 00:00:00+01	0.85	t	0.82
P5-012	X/Twitter	@Keir_Starmer	Keir Starmer	Party Leader	Labour	t	2027-02-01 00:00:00+00	\N	Deepfakes are being used to spread lies and undermine our democracy. I raised this at PMQs today — X must take responsibility. The Online Safety Act exists for a reason. Platforms that fail to tackle harmful content will face the consequences.	Deepfake image processing; platform obligations; AI-generated content	\N	deepfakes; Online Safety Act; X; platform accountability; AI-generated content; pro-enforcement	Primary	Pro-enforcement	67000	2027-05-04 00:00:00+01	0.85	t	0.88
P5-013	X/Twitter	@KemiBadenoch	Kemi Badenoch	Party Leader	Conservative	f	2027-02-01 00:00:00+00	\N	Deepfake regulation must be balanced. We need strong protections against harmful synthetic media but we cannot regulate in a way that stifles free expression or legitimate AI development. The Online Safety Act must be implemented before we add yet more layers of regulation.	AI-generated content; platform regulation; AI governance	\N	deepfakes; Online Safety Act; balanced regulation; Conservative; Kemi Badenoch; AI	Secondary	Neutral	18000	2027-05-04 00:00:00+01	0.85	t	0.82
P5-014	X/Twitter	@EdwardJDavey	Ed Davey	Party Leader	Liberal Democrats	f	2027-02-01 00:00:00+00	\N	Mandatory AI watermarking now. Every piece of AI-generated content should be clearly labelled. Platforms have no excuse for allowing deepfakes of political figures to spread. Liberal Democrats will introduce a Digital Bill of Rights to protect everyone's online rights.	AI-generated content; deepfakes; digital rights; platform transparency	\N	deepfakes; AI watermarking; Digital Bill of Rights; Lib Dems; Ed Davey; online safety	Primary	Pro-enforcement	9600	2027-05-04 00:00:00+01	0.85	t	0.88
P5-015	X/Twitter	@Nigel_Farage	Nigel Farage	Party Leader	Reform UK	f	2026-09-07 00:00:00+01	\N	The Online Safety Act is an attack on free speech. Peter Kyle wants to censor the internet and silence dissent. Reform UK will repeal this authoritarian law and restore British freedoms online. The government is using children as an excuse for censorship.	Platform obligations; online safety; content moderation	\N	Online Safety Act; repeal; free speech; Reform UK; Farage; censorship; deregulatory	Secondary	Deregulatory	34000	2027-05-04 00:00:00+01	0.85	t	0.72
P5-016	X/Twitter	@CarlaForGreen	Carla Denyer	Party Leader	Green	f	2025-05-04 00:00:00+01	\N	Big tech companies must not be allowed to hoover up our personal data to train AI systems without proper consent. The ICO must act. We need binding regulation on AI — not voluntary codes — to protect people from algorithmic discrimination and surveillance capitalism.	AI training data; personal data; algorithmic discrimination; consent	\N	AI regulation; consent; algorithmic discrimination; Green Party; ICO; surveillance capitalism; binding regulation	Primary	Pro-enforcement	4100	2027-05-04 00:00:00+01	0.85	t	0.9
P5-017	X/Twitter	@CarlaForGreen	Carla Denyer	Party Leader	Green	f	2025-01-10 00:00:00+00	\N	Greens call on ICO to urgently investigate Reform UK's use of voter data after multiple reports of unsolicited targeted messaging. Data protection law applies to political parties too. The ICO must not shy away from enforcement against those with political power.	Political data processing; direct marketing; electoral data	\N	ICO enforcement; voter data; political data; Reform UK; Green Party; PECR; data protection	Primary	Pro-enforcement	5900	2027-05-04 00:00:00+01	0.85	t	0.88
P5-018	X/Twitter	@ZackPolanski	Zack Polanski	Party Leader	Green	f	2027-01-09 00:00:00+00	\N	Elected Green co-leader. My first act will be demanding the government introduce a proper AI regulator with teeth. Not the ICO stretched thin. Not voluntary codes. A dedicated regulator empowered to stop AI harms before they happen — especially for children and marginalised communities.	AI regulation; automated decision-making; children's data	\N	Green Party; AI regulator; Zack Polanski; AI regulation; children; ICO; binding regulation	Primary	Pro-enforcement	12800	2027-05-04 00:00:00+01	0.85	t	0.88
P5-019	X/Twitter	@johnnedwards_nz	John Edwards	Other	N/A	f	2023-06-12 00:00:00+01	\N	Spoke at TechUK Digital Ethics Summit today. My message: authentic use of AI builds trust. Our action against Snap's My AI shows we will not hesitate to act when companies fail to protect people — especially children — from AI risks. Come to us with your AI questions.	Generative AI; DPIA; children's data; AI risk	\N	ICO Commissioner; AI; Snap; My AI; children; DPIA; trust; enforcement	Primary	Pro-enforcement	3100	2027-05-04 00:00:00+01	0.85	t	0.95
P5-020	X/Twitter	@alexdaviesjones	Alex Davies-Jones MP	Shadow Minister	Labour	f	2025-03-11 00:00:00+00	\N	As Shadow Digital Minister I am pressing the government on the timeline for AI regulation. Labour in opposition fought hard for binding rules. Now in government we must deliver. The AI Bill must come forward in 2025 — tech companies cannot be left to self-regulate indefinitely.	AI regulation; frontier AI; digital regulation	\N	AI regulation; AI Bill; shadow minister; Alex Davies-Jones; Labour; binding regulation; DSIT	Secondary	Pro-enforcement	2400	2027-05-04 00:00:00+01	0.8	t	0.88
\.


--
-- Data for Name: p6_parliamentary_qa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.p6_parliamentary_qa (pqa_id, question_date, answer_date, question_type, asking_mp, asking_party, asking_party_gov, answering_minister, answering_department, answering_party, question_text, answer_text, processing_activities, topic_tags, topic_relevance_score, priority_level, government_position, ico_mentioned, enforcement_signal, source_url, rss_guid, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
P6-001	2025-03-01	2025-10-01	Written	Darren Jones	Labour	f	Viscount Camrose	DSIT	Conservative	To ask His Majesty's Government what assessment they have made of the adequacy of the current regulatory framework for artificial intelligence with respect to data protection.	The UK GDPR and Data Protection Act 2018 already apply to AI systems that process personal data. The ICO has issued guidance on AI and data protection and is conducting audits of high-risk AI use cases. The government's pro-innovation approach tasks existing regulators including the ICO to apply existing powers within their remits. Regulators have been asked to publish AI strategies by April 2024.	AI data processing; automated decision-making; ICO regulatory remit	AI regulation; UK GDPR; data protection; ICO; pro-innovation; AI strategy	0.95	Primary	Supportive of Enforcement	t	0.65	https://questions-statements.parliament.uk/written-questions/detail/2024-01-15/9578	\N	2027-05-04 00:00:00+01	0.9	t
P6-002	2024-06-02	2025-01-02	Written	Lord Bassam of Brighton	Labour	f	Viscount Camrose	DSIT	Conservative	To ask His Majesty's Government what steps they are taking to require regulators to set out their approaches to AI regulation.	The government is asking a number of regulators to publish an update outlining their strategic approach to AI by 30 April 2024. This includes the ICO which has issued guidance on AI and data protection and is well positioned to regulate data protection aspects of AI within its existing remit. The central function in DSIT will drive coherence across the regulatory landscape.	AI processing across sectors; ICO regulatory strategy	AI regulation; ICO strategy; DSIT; April 2024 deadline; regulator approaches; coherence	0.92	Primary	Supportive of Enforcement	t	0.6	https://questions-statements.parliament.uk/written-statements/detail/2024-02-06/hcws247	\N	2027-05-04 00:00:00+01	0.9	t
P6-003	2024-12-03	2025-07-03	Written	Kim Leadbeater	Labour	f	Viscount Camrose	DSIT	Conservative	To ask the Secretary of State for Science Innovation and Technology what steps the Government is taking to ensure that the use of facial recognition technology by police forces complies with data protection law.	The ICO has powers to investigate and take enforcement action where facial recognition technology is used in breach of data protection law. The ICO issued an opinion on live facial recognition in 2022. The Home Office and DSIT are working with police forces on governance frameworks. Any use of biometric data must comply with UK GDPR requirements for special category data.	Biometric data processing; facial recognition; police surveillance	facial recognition; biometrics; police; data protection; ICO enforcement; special category data	0.88	Primary	Neutral	t	0.7	https://questions-statements.parliament.uk/written-questions/detail/2024-03-12/facial-recognition	\N	2027-05-04 00:00:00+01	0.9	t
P6-004	2025-11-04	2026-06-04	Written	Baroness Kidron	Crossbench	f	Viscount Camrose	DSIT	Conservative	To ask His Majesty's Government what assessment they have made of the risks to children's personal data from generative artificial intelligence systems and what steps are being taken to ensure the ICO enforces the Children's Code in this context.	The ICO is the designated regulator for children's data protection including under the Age Appropriate Design Code (Children's Code). The ICO has opened an investigation into Snap's My AI chatbot following concerns about data protection risk assessment. The ICO's generative AI consultation series includes consideration of how existing protections including the Children's Code apply to AI systems. We expect the ICO to use its full enforcement powers where children's data is at risk.	Children's data processing; generative AI; DPIA obligations; Children's Code	generative AI; children's data; Children's Code; AADC; ICO enforcement; Snap My AI	0.95	Primary	Supportive of Enforcement	t	0.75	https://questions-statements.parliament.uk/written-questions/detail/2024-04-23/baroness-kidron-genai	\N	2027-05-04 00:00:00+01	0.9	t
P6-005	2025-02-05	2025-09-05	Written	Lord Holmes of Richmond	Conservative	t	Viscount Camrose	DSIT	Conservative	To ask His Majesty's Government when they plan to introduce legislation to regulate artificial intelligence.	The government has set out its approach in the AI regulation white paper response of February 2024. We are not rushing to legislate but will do so when confident it is the right thing to do. The principles-based approach through existing regulators including the ICO is the right framework at this stage. We are monitoring developments and stand ready to legislate if gaps emerge.	AI processing across all sectors	AI legislation; AI regulation timeline; pro-innovation; no AI Act; sector-led	0.88	Primary	Neutral	f	0.45	https://questions-statements.parliament.uk/written-questions/detail/2025-03-25/41096	\N	2027-05-04 00:00:00+01	0.9	t
P6-006	2025-04-10	2025-11-10	Written	Lord Clement-Jones	Liberal Democrats	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what assessment they have made of the data protection implications of the National Data Library announced in the AI Opportunities Action Plan.	The National Data Library will be developed with strong safeguards and in full compliance with UK data protection law including the UK GDPR and Data Protection Act 2018. The ICO will be consulted as the library is developed. Data sharing for research purposes must comply with the lawful basis requirements and the purpose limitation principle. The government is committed to safe and responsible use of public data.	Research data processing; data sharing; public sector data; purpose limitation	National Data Library; data protection; ICO; research; safeguards; public data; AI Action Plan	0.9	Primary	Supportive of Enforcement	t	0.55	https://questions-statements.parliament.uk/written-questions/detail/2024-10-16/hl11069	\N	2027-05-04 00:00:00+01	0.9	t
P6-007	2025-04-10	2025-11-10	Written	Lord Freyberg	Crossbench	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government whether they were aware that Anthropic downloaded pirated books to train its Claude AI model when selecting Anthropic as the supplier for the GOV.UK chat service and whether a risk assessment was conducted for the use of a model developed using unlawfully accessed copyright-protected works.	Risk assessments have been undertaken in accordance with government standards including consideration of ethical legal and data protection risks. The Government Digital Service recognises the importance of ethical legal and data protection considerations in the use of large language models. GOV.UK Chat is in active development and accesses Anthropic models through an existing AWS agreement. A range of models from multiple suppliers have been considered.	AI training data; copyright; government AI procurement; data protection assessment	AI training data; copyright; Anthropic; GOV.UK Chat; risk assessment; procurement; data protection	0.85	Secondary	Neutral	f	0.5	https://questions-statements.parliament.uk/written-questions/detail/2025-10-16/HL11069/	\N	2027-05-04 00:00:00+01	0.9	t
P6-008	2025-04-10	2025-11-10	Written	Lord Clement-Jones	Liberal Democrats	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what steps DSIT is taking to ensure organisations deploying AI tools in the workplace comply with data protection and cybersecurity obligations.	DSIT supports the use of AI tools in UK workplaces and has established voluntary baseline cybersecurity requirements for all AI systems and models. The Government's Code of Practice for the Cybersecurity of AI published in 2025 identifies requirements for securing AI systems. The ICO has issued employment practices guidance and guidance on AI and data protection and has the authority to investigate and impose penalties for non-compliance.	Workplace AI processing; employee data; cybersecurity; data protection compliance	AI workplace; cybersecurity; employment; ICO enforcement; Code of Practice; data protection	0.88	Primary	Supportive of Enforcement	t	0.65	https://questions-statements.parliament.uk/written-questions/detail/2025-10-16/hl11090	\N	2027-05-04 00:00:00+01	0.9	t
P6-009	2024-10-11	2025-05-11	Written	Lord Faulks	Crossbench	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what safeguards are in place to prevent AI chatbot services from generating suicide and self-harm content accessible to children.	Once deployed many AI services are captured by the Online Safety Act 2023 which places robust duties on in-scope user-to-user and search services including those deploying generative AI chatbots to prevent users from encountering illegal suicide and self-harm content. Ofcom is responsible for enforcement of the Online Safety Act. The ICO's Children's Code requires services likely to be accessed by children to provide data protection by default.	AI chatbot processing; children's data; online safety; content moderation	AI chatbots; Online Safety Act; children; self-harm; suicide content; Ofcom; ICO Children's Code	0.85	Primary	Supportive of Enforcement	t	0.7	https://questions-statements.parliament.uk/written-questions/detail/2025-11-10/hl11766	\N	2027-05-04 00:00:00+01	0.9	t
P6-010	2026-03-03	2026-10-03	Written	Lord Hunt of Kings Heath	Labour	t	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what assessment they have made of the data protection risks of using artificial intelligence in NHS settings and what guidance has been issued to NHS organisations.	The government has assessed these risks through the AI Playbook for UK Government and the Generative AI Framework for UK Government both published in February 2025. NHS England has published information governance guidance on AI reviewed by a working group including the ICO and National Data Guardian. The guidance addresses confidentiality lawful processing consent and human oversight and applies to NHS organisations considering or deploying AI including generative AI tools.	Health data processing; NHS AI; clinical AI; DPIA; special category data	NHS AI; health data; data protection; ICO; DPIA; generative AI; human oversight; clinical settings	0.92	Primary	Supportive of Enforcement	t	0.65	https://questions-statements.parliament.uk/written-questions/detail/2026-03-03/hl15141	\N	2027-05-04 00:00:00+01	0.9	t
P6-011	2027-01-03	2025-01-04	Written	Lord Clement-Jones	Liberal Democrats	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government when they plan to introduce legislation specifically regulating artificial intelligence and what role the Information Commissioner will play in any new statutory framework.	The government committed to AI legislation in the King's Speech July 2024. We are taking the time to get this right and intend to introduce a bill in the second half of 2026. The legislation will focus on requirements on developers of the most powerful AI models. The ICO will continue as the lead data protection regulator for AI and its role in any new statutory framework will be considered as part of the legislative process.	Frontier AI processing; AI governance; ICO regulatory mandate	AI legislation; AI Bill; ICO role; frontier AI; 2026; statutory framework	0.9	Primary	Neutral	t	0.55	https://questions-statements.parliament.uk/written-questions/detail/2025-03-25/41096	\N	2027-05-04 00:00:00+01	0.9	t
P6-012	2025-12-02	2026-07-02	Written	Stephen Kinnock	Labour	t	Feryal Clark	DSIT	Labour	To ask the Secretary of State for Science Innovation and Technology what steps the Department for Work and Pensions is taking to ensure algorithmic decision-making systems comply with data protection law and the right to explanation under UK GDPR.	DWP is committed to publishing details about AI and algorithmic tools through the Algorithmic Transparency Recording Standard. DWP has published its first ATRS record for its Employment and Support Allowance Online Medical Matching tool. The ICO has powers to audit and investigate automated decision-making and has issued guidance on profiling and automated decisions. DWP processes personal data in accordance with UK GDPR and the DPA 2018.	Automated decision-making; benefits processing; DWP algorithms; data subject rights	ADM; DWP; algorithmic transparency; ATRS; ICO; automated decisions; data subject rights; benefits	0.9	Primary	Supportive of Enforcement	t	0.7	https://questions-statements.parliament.uk/written-questions/detail/2025-02-12/31024/	\N	2027-05-04 00:00:00+01	0.9	t
P6-013	2025-07-11	2026-02-11	Oral	Lord Bishop of Coventry	Crossbench	f	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what assessment they have made of the national security implications of artificial intelligence systems that process personal data of UK citizens.	The government takes the national security implications of AI very seriously. The AI Security Institute conducts evaluations of frontier AI models for dangerous capabilities. The Home Office collaborates with DSIT and the intelligence community to assess AI threats. The ICO works with the National Cyber Security Centre on data protection aspects of AI security. Where AI systems process personal data of UK citizens they must comply with UK GDPR regardless of the developer's jurisdiction as affirmed in the Clearview AI Upper Tribunal ruling.	Frontier AI; national security; personal data of UK citizens; biometric data	AI security; national security; ICO; AISI; Clearview; UK GDPR jurisdiction; frontier AI	0.88	Secondary	Neutral	t	0.6	https://questions-statements.parliament.uk/written-questions/detail/2025-11-07/hl11310	\N	2027-05-04 00:00:00+01	0.9	t
P6-014	2025-02-12	2025-09-12	Written	Lord Stevenson of Balmacara	Labour	t	Baroness Jones of Whitchurch	DSIT	Labour	To ask His Majesty's Government what the current status is of the ICO investigation into Clearview AI and what steps are being taken to enforce data protection obligations on companies that scrape personal data from the internet to train AI models.	The Upper Tribunal ruled in October 2025 that the ICO does have jurisdiction to take enforcement action against Clearview AI and that processing does not fall outside UK GDPR because services were provided to foreign law enforcement agencies. The ICO's enforcement notice and monetary penalty of £7.5 million are therefore reinstated. This ruling is significant for AI developers who scrape personal data of UK residents to train AI models regardless of where the developer is based.	Biometric data; web scraping; AI training data; ICO enforcement jurisdiction	Clearview AI; web scraping; AI training; ICO enforcement; Upper Tribunal; UK GDPR jurisdiction; biometrics	0.95	Primary	Supportive of Enforcement	t	0.85	https://questions-statements.parliament.uk/written-questions/detail/2025-12-02/96093/	\N	2027-05-04 00:00:00+01	0.9	t
P6-015	2025-04-01	2025-11-01	Written	Damian Collins	Conservative	t	Viscount Camrose	DSIT	Conservative	To ask the Secretary of State for Science Innovation and Technology what discussions the Government has had with the ICO about its capacity and resourcing to regulate artificial intelligence.	The government has regular discussions with the ICO about its regulatory priorities and resourcing. The ICO is primarily funded through the data protection fee paid by organisations registered with the ICO. The government announced over £100 million to help regulators including the ICO build technical capabilities to regulate AI. The ICO is taking forward a programme of consensual AI audits and has established an Innovation Advice service for AI developers.	AI regulation; ICO resourcing; regulatory capacity	ICO; resourcing; AI regulation; capacity; £100m; audits; Innovation Advice	0.88	Primary	Supportive of Enforcement	t	0.65	https://questions-statements.parliament.uk/written-questions/detail/2024-01-16/ico-ai-capacity	\N	2027-05-04 00:00:00+01	0.9	t
\.


--
-- Data for Name: r1_enforcement_register; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r1_enforcement_register (enforcement_id, ico_reference, org_name, org_type, org_size, action_date, action_type, outcome, penalty_gbp, penalty_as_max, severity_tier, aggravating_factors, mitigating_factors, appealed, appeal_outcome, processing_activities, legislation_breached, gdpr_principles, special_category_data, cross_border, ai_specific, prior_ico_contact, prior_contact_types, prior_contact_count, days_prior_contact, org_type_recidivism_rate, enforcement_signal, nlp_confidence, source_url, raw_summary, ingested_at, manually_reviewed, regulatory_regime) FROM stdin;
R1-001	\N	Capita plc; Capita Pension Solutions Limited	Outsourcing / Public sector services	Large (250+)	2026-03-10	Monetary Penalty Notice	Settled	14000000.00	0.311	Critical	Delayed containment (58hrs after suspicious activity detected); large-scale breach affecting 6.6m individuals; multiple organisations affected	Early settlement; no appeal; written representations submitted; remediation taken	f		Security processing; vendor data processing	UK GDPR Article 5(1)(f); Article 32	Integrity and confidentiality	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/10/capita-plc/	ICO fined Capita plc £8m and Capita Pension Solutions Ltd £6m (total £14m) for a March 2023 ransomware breach. The breach exposed personal data of 6,656,037 individuals across multiple client organisations. A key failure was a 58-hour delay in quarantining a compromised device. Original proposed fine was £45m, reduced after voluntary settlement in October 2025.	2027-04-04 00:00:00+01	t	UK GDPR
R1-002	\N	Advanced Computer Software Group Ltd	Technology / Software	Large (250+)	2027-03-03	Monetary Penalty Notice	Upheld	3070000.00	0.068	High	Inadequate security measures; breach caused disruption to NHS services; processor handling sensitive health data	Self-reported elements; cooperation with ICO	f		Security processing; health data processing; processor obligations	UK GDPR Article 5(1)(f); Article 32	Integrity and confidentiality	t	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/03/advanced-computer-software-group-limited/	ICO fined Advanced Computer Software Group Ltd £3.07m for a 2022 ransomware attack that disrupted NHS services. The company was acting as a data processor. Breach involved sensitive health records. NHS services including patient referrals were disrupted.	2027-04-04 00:00:00+01	t	UK GDPR
R1-003	\N	23andMe Inc.	Consumer genetics / Research	Large (250+)	2025-05-06	Monetary Penalty Notice	Upheld	2310000.00	0.051	High	Failure to implement appropriate security measures; special category genetic data compromised; large-scale breach via credential stuffing	Breach originated externally via credential stuffing (not direct system failure)	f		Genetic data processing; consumer profiling	UK GDPR Article 5(1)(f); Article 32	Integrity and confidentiality	t	t	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/06/23andme/	ICO fined 23andMe £2.31m for failing to protect special category genetic data of 155,592 UK users. Hackers used credential stuffing to access accounts in 2023. ICO found the company failed to implement appropriate security measures including enhanced protections for sensitive genetic data.	2027-04-04 00:00:00+01	t	UK GDPR
R1-004	\N	Police Service of Northern Ireland (PSNI)	Law enforcement / Public sector	Large (250+)	2024-03-10	Monetary Penalty Notice	Upheld	750000.00	0.017	High	Entire workforce data exposed; sensitive data including covert officers; serious risk to individual safety	Public sector organisation; immediate remediation steps taken	f		HR data processing; law enforcement data	UK GDPR Article 5(1)(f); Article 32; DPA 2018 Part 3	Integrity and confidentiality	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/10/police-service-of-northern-ireland-mpn/	ICO fined PSNI £750,000 for accidentally publishing the personal data of its entire workforce (approximately 10,000 officers and staff) including names, ranks, and locations. Data was published in response to a Freedom of Information request. Included data on covert officers, creating serious safety risks.	2027-04-04 00:00:00+01	t	UK GDPR
R1-005	\N	TikTok Information Technologies UK Ltd; TikTok Inc.	Social media / Technology	Large (250+)	2024-03-05	Monetary Penalty Notice	Under Appeal	12700000.00	0.282	Critical	Children's data misused; failure to obtain valid consent for under-13s; lack of transparency; large-scale processing		t	Pending full tribunal hearing	Children's data processing; consent management; transparency	UK GDPR Article 5(1)(a); Article 8; Article 12; Article 13	Lawfulness fairness and transparency	f	t	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2023/05/tiktok/	ICO fined TikTok £12.7m for misusing children's data. ICO found TikTok allowed up to 1.4m UK children under 13 to use the platform without parental consent, and failed to provide adequate privacy information. TikTok appealed; tribunal ruled in 2025 that ICO had jurisdiction and case proceeds to full hearing.	2027-04-04 00:00:00+01	t	UK GDPR
R1-006	\N	Join the Triboo Ltd	Online recruitment / Technology	Medium (50-249)	2024-02-04	Monetary Penalty Notice	Upheld	130000.00	0.003	Medium	107 million spam emails sent; poorly signposted privacy policy; registration treated as blanket consent		t	Fine upheld; enforcement notice partially upheld	Direct marketing; consent management	PECR Regulation 22	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2023/04/join-the-triboo-limited-mpn/	ICO fined Join the Triboo £130,000 and issued enforcement notice for sending 107 million spam emails to over 400,000 people without consent between August 2019 and August 2020. Company appealed; First-tier Tribunal upheld the fine in May 2024, finding the privacy policy was poorly signposted and registration could not constitute consent to direct marketing.	2027-04-04 00:00:00+01	t	PECR
R1-007	\N	Green Spark Energy Ltd	Energy / Utilities	Small (10-49)	2027-04-08	Monetary Penalty Notice	Upheld	\N	\N	Medium	9.5m automated marketing calls made; misleading statements used to pressure homeowners; search warrant executed		f		Direct marketing; automated calling	PECR Regulation 19	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/09/green-spark-energy-ltd-monetary-penalty-notice/	ICO issued fine and enforcement notice to Green Spark Energy Ltd for making 9,587,050 automated marketing calls between May 2023 and May 2024 without prior consent. Calls contained misleading statements about health risks from loft insulation. ICO executed a search warrant in March 2024 to obtain evidence. 497 complaints received.	2027-04-04 00:00:00+01	t	PECR
R1-008	\N	Home Improvement Marketing Ltd	Marketing / Utilities	Small (10-49)	2027-04-08	Enforcement Notice	Upheld	\N	\N	Low	2.4m automated calls made without consent; no opt-out mechanism; multiple calls per day to same individuals		f		Direct marketing; automated calling	PECR Regulation 19	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/09/home-improvement-marketing-ltd-monetary-penalty-notice/	ICO issued enforcement notice to Home Improvement Marketing Ltd for transmitting 2,449,380 automated marketing calls between May-August 2023 without prior consent. Complainants reported multiple calls per day. Software had no opt-out option. Part of wider ICO operation targeting energy and home improvement sector.	2027-04-04 00:00:00+01	t	PECR
R1-009	\N	Clearview AI Inc.	AI / Facial recognition technology	Large (250+)	2023-11-05	Monetary Penalty Notice	Overturned on Appeal	7500000.00	0.167	Critical	Unlawful scraping of facial images of UK residents; no lawful basis; processing without knowledge of data subjects; commercial exploitation of biometric data		t	Upper Tribunal overturned FTT; ICO enforcement reinstated	Biometric data processing; web scraping; AI training data	UK GDPR Article 5; Article 6; Article 9; Article 14	Lawfulness fairness and transparency; Data minimisation	t	t	t	f		\N	\N	\N	\N	1	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2025/10/uk-upper-tribunal-hands-down-judgment-on-clearview-ai-inc/	ICO fined Clearview AI £7.5m for unlawfully scraping facial images of UK residents to build a global biometric database. FTT overturned in November 2023 ruling ICO lacked jurisdiction. Upper Tribunal reversed FTT in October 2025, finding ICO did have jurisdiction as Clearview monitored UK residents' behaviour. Case represents landmark ruling on extraterritorial reach of UK GDPR.	2027-04-04 00:00:00+01	t	UK GDPR
R1-010	\N	Experian Limited	Credit reference / Financial services	Large (250+)	2020-12-10	Enforcement Notice	Overturned on Appeal	\N	\N	High	Opaque processing of personal data for marketing; data traded without individuals' knowledge; lack of transparency in direct marketing ecosystem	Long-running investigation; complex business model; Experian cooperated	t	ICO appeal to Upper Tribunal dismissed (April 2024); FTT substitute enforcement notice stands	Direct marketing profiling; data brokerage; credit referencing	UK GDPR Article 5(1)(a); Article 14	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/04/ico-statement-on-upper-tribunal-ruling/	ICO issued enforcement notice to Experian in October 2020 following two-year investigation into credit reference agencies' use of personal data for direct marketing. First-tier Tribunal ruled in Experian's favour on key issues in February 2023, replacing ICO enforcement notice with a substitute version. ICO appealed to Upper Tribunal, which dismissed the appeal in April 2024. Significant case on legitimate interests and transparency obligations for data brokers.	2027-04-04 00:00:00+01	t	UK GDPR
R1-011	\N	Poxell Ltd	Home improvement / Energy efficiency	Small (10-49)	2025-04-01	Monetary Penalty Notice	Upheld	150000.00	0.3	Medium	2.6m calls to TPS-registered numbers; no due diligence on consent; no PECR compliance policies or staff training		f		Direct marketing; automated calling	PECR Regulation 21; Regulation 24	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/01/poxell-ltd-mpn/	ICO fined Poxell Ltd £150,000 for making 2,647,805 unsolicited direct marketing calls to TPS-registered numbers between March and July 2022, promoting energy efficiency products such as double glazing and resin driveways. Company failed to screen against TPS or maintain PECR compliance procedures.	2027-04-04 00:00:00+01	t	PECR
R1-012	\N	Skean Homes Ltd	Home improvement / Energy efficiency	Small (10-49)	2025-04-01	Monetary Penalty Notice	Upheld	100000.00	0.2	Medium	614,342 calls to TPS-registered numbers; relied on third-party lead generator without verifying consent; no PECR compliance procedures	Negligent rather than deliberate; no aggravating or mitigating factors identified by ICO	f		Direct marketing; automated calling	PECR Regulation 21; Regulation 24	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/01/skean-homes-ltd-mpn/	ICO fined Skean Homes Ltd £100,000 for making 614,342 unsolicited direct marketing calls to TPS-registered numbers. Company promoted energy-saving home improvements and relied on a lead generator to screen calls, but failed to verify consent or maintain any PECR compliance documentation. Contravention found to be negligent.	2027-04-04 00:00:00+01	t	PECR
R1-013	\N	HelloFresh (Grocery Delivery E-Services UK Ltd)	Food delivery / Consumer subscription	Large (250+)	2024-12-01	Monetary Penalty Notice	Upheld	140000.00	0.028	Medium	79m spam emails and 1m spam texts sent; opt-in statement did not inform customers about text marketing; messages sent after opt-out and subscription cancellation; messages sent at unsociable hours	Full cooperation with ICO; remediation steps taken; infringement found to be negligent not deliberate	f		Direct marketing; consent management; email marketing	PECR Regulation 22	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/01/grocery-delivery-e-services-uk-ltd-ta-hellofresh/	ICO fined HelloFresh £140,000 for sending 79,779,279 spam emails and 1,113,734 spam texts between August 2021 and February 2022. The opt-in statement used at registration did not make clear that customers were consenting to receive text marketing. 15,221 complaints received via the spam reporting service. ICO noted infringement was negligent rather than deliberate and gave credit for cooperation and remediation.	2027-04-04 00:00:00+01	t	PECR
R1-014	\N	LADH Limited	Financial services	Micro (<10)	2025-07-01	Monetary Penalty Notice	Upheld	50000.00	0.1	Low	31,329 SMS messages sent without consent; sender identity not disclosed in messages; no opt-out mechanism; company relied on unverified third-party consent claims		f		Direct marketing; consent management; SMS marketing	PECR Regulation 22; Regulation 23	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/01/ladh-limited-en/	ICO fined LADH Limited £50,000 for sending 31,329 unsolicited direct marketing SMS messages between March and April 2022 promoting debt advice services. Company claimed it received verbal assurance from a third party that recipients had consented. ICO found this reliance on unverified third-party consent claims left the company open to enforcement action.	2027-04-04 00:00:00+01	t	PECR
R1-015	\N	Digivo Media Limited (t/a Rid My Debt)	Financial services / Debt management	Small (10-49)	2023-03-10	Monetary Penalty Notice	Upheld	50000.00	0.1	Low	415,041 texts sent without valid consent; mandatory consent checkbox used (not freely given); consent form did not make marketing nature clear; financially vulnerable recipients targeted		f		Direct marketing; consent management; SMS marketing; debt advice	PECR Regulation 22	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2023/10/digivo-media-limited-mpn/	ICO fined Digivo Media Limited £50,000 for sending 415,041 unsolicited SMS messages to financially vulnerable individuals between March and September 2021. Recipients were users of the Rid My Debt debt solutions website who had ticked a mandatory consent checkbox — making consent a precondition for service and therefore not freely given. 942 spam reports received.	2027-04-04 00:00:00+01	t	PECR
R1-016	\N	Argentum Data Solutions Ltd	Technology / Data processing and hosting	Small (10-49)	2025-02-10	Monetary Penalty Notice	Upheld	65000.00	0.13	Medium	2.3m SMS messages sent without consent; platform allowed third parties to send messages through its infrastructure; no evidence of consents obtained		f		Direct marketing; SMS marketing; data processing platform	PECR Regulation 22; Regulation 23	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2023/10/argentum-data-solutions-ltd-mpn/	ICO fined Argentum Data Solutions Ltd £65,000 for sending and allowing third parties to send 2,330,423 unsolicited SMS marketing messages between January 2021 and January 2022. As an SMS platform provider ADS was held responsible for messages sent through its infrastructure. 10,242 complaints received via the Mobile UK spam reporting service. No evidence of valid consents provided.	2027-04-04 00:00:00+01	t	PECR
R1-017	\N	MCP Online Ltd	Financial services / Pensions	Micro (<10)	2025-04-09	Monetary Penalty Notice	Upheld	55000.00	0.11	Medium	20,939 calls to CTPS/TPS-registered numbers; attempted to mask activity; no identifiable operational premises; backdated company records; marketing continued after ICO investigation letter sent		f		Direct marketing; telephone marketing; pension advice	PECR Regulation 21; Regulation 24	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2023/09/mcp-online-ltd-en/	ICO fined MCP Online Ltd £55,000 for making 20,939 unsolicited pension marketing calls to CTPS/TPS-registered numbers. Significant aggravating factors: company took steps to mask its activity, had no identified operational premises, failed to file accounts, set up under a similar name (MCP Online Group Limited) to evade regulatory action, backdated directorship records, and continued marketing after the first ICO investigation letter.	2027-04-04 00:00:00+01	t	PECR
R1-018	\N	Penny Appeal	Charity / International aid	Small (10-49)	2024-01-03	Enforcement Notice	Upheld	\N	\N	Low	461,650 texts sent without consent; second batch of texts sent during ICO investigation; messages received late at night; complainants had opted out		f		Direct marketing; charity marketing; SMS marketing	PECR Regulation 22	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/03/pinnacle-life-limited-mpn/	ICO issued enforcement notice to Penny Appeal (international aid charity) for sending approximately 461,650 unsolicited SMS messages over ten days to 52,179 individuals who had never consented to receive marketing. Messages included a further batch sent during Ramadan while the ICO investigation was ongoing. Complaints described messages as intrusive and often received late at night.	2027-04-04 00:00:00+01	t	PECR
R1-019	\N	Pinnacle Life Limited	Financial services / Life insurance	Small (10-49)	2024-07-03	Monetary Penalty Notice	Upheld	80000.00	0.16	Medium	47,998 calls to TPS-registered numbers; company attempted to disguise identity to avoid compliance with cease-contacting orders; calls about life insurance and later life planning		f		Direct marketing; telephone marketing; insurance	PECR Regulation 21; Regulation 24	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2024/03/pinnacle-life-limited-mpn/	ICO fined Pinnacle Life Limited £80,000 for making 47,998 unsolicited calls to TPS-registered numbers between May 2021 and May 2022 promoting life insurance and later life planning products. Significant aggravating factor: company attempted to disguise its identity to avoid having to comply with cease-contacting orders, resulting in a higher fine.	2027-04-04 00:00:00+01	t	PECR
R1-020	\N	Bharat Singh Chand (sole trader)	Marketing / Debt advice / Energy grants	Micro (<10)	2026-04-09	Monetary Penalty Notice	Under Appeal	200000.00	0.4	High	966,449 spam texts sent; 19,138 complaints received; used hundreds of unregistered prepaid SIM cards; sender identity concealed; no consent; linked to Taipan Trading investigation		t	Pending	Direct marketing; SMS marketing; debt advice; energy grants	PECR Regulation 22; Regulation 23	Lawfulness fairness and transparency	f	f	f	f		\N	\N	\N	\N	1	https://ico.org.uk/action-weve-taken/enforcement/2025/09/bharat-singh-chand-1/	ICO fined sole trader Bharat Singh Chand £200,000 for sending 966,449 unsolicited spam texts between December 2023 and July 2024 about debt solutions and energy saving grants. Case emerged from a related investigation into Taipan Trading Ltd (Daniel Bentley). Chand used hundreds of unregistered prepaid SIM cards and concealed sender identity. 19,138 complaints to the 7726 spam reporting service. Chand is appealing the fine.	2027-04-04 00:00:00+01	t	PECR
\.


--
-- Data for Name: r2_ico_news; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r2_ico_news (news_id, title, publication_date, content_type, processing_activities, topic_tags, topic_relevance_score, signal_investigation, signal_consultation, enforcement_signal, source_url, rss_guid, raw_text, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
R2-001	ICO issues preliminary enforcement notice against Snap over My AI chatbot	2023-06-10	Investigation Announcement	AI chatbot processing; children's data; DPIA obligations	generative AI; children's data; DPIA; Snapchat; AI risk assessment	0.95	t	f	0.85	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2023/10/uk-information-commissioner-issues-preliminary-enforcement-notice-against-snap/	\N	ICO issued Snap Inc and Snap Group Limited with a preliminary enforcement notice over the My AI generative AI chatbot. Investigation found Snap had not adequately assessed data protection risks posed by the chatbot especially to children aged 13-17. Snap launched My AI in February 2023 for Snapchat+ subscribers then to all UK users in April 2023. ICO provisionally found the DPIA was inadequate. If a final enforcement notice were issued Snap could be required to stop offering My AI to UK users.	2027-04-04 00:00:00+01	1	t
R2-002	ICO warns organisations must not ignore data protection risks as Snap My AI investigation concludes	2024-01-05	News	AI chatbot processing; DPIA obligations; children's data; AI risk management	generative AI; Snapchat; DPIA; children's data; AI compliance	0.9	f	f	0.7	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/05/ico-warns-organisations-must-not-ignore-data-protection-risks-as-it-concludes-snap-my-ai-chatbot-investigation/	\N	ICO concluded investigation into Snap My AI after Snap carried out a compliant risk assessment and implemented appropriate mitigations. ICO warned all organisations deploying AI that they must not ignore data protection risks. ICO confirmed it will continue monitoring My AI rollout. Enforcement notice not finalised as Snap complied but warning issued to wider industry.	2027-04-04 00:00:00+01	1	t
R2-003	ICO orders Serco Leisure to stop using facial recognition technology for employee attendance	2025-11-02	News	Biometric data processing; employee monitoring; facial recognition	biometrics; facial recognition; employee monitoring; workplace surveillance; enforcement notice	0.88	f	f	0.9	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/02/ico-orders-serco-leisure-to-stop-using-facial-recognition-technology/	\N	ICO issued enforcement notices to Serco Leisure and nine associated community leisure trusts ordering them to stop using facial recognition technology and fingerprint scanning to monitor attendance of over 2,000 employees across 38 facilities. ICO found employees were not offered a genuine alternative. Enforcement notice also required destruction of all biometric data. ICO simultaneously published new biometric data guidance. Commissioner stated this action put industry on notice that biometric technologies cannot be deployed lightly.	2027-04-04 00:00:00+01	1	t
R2-004	Regulating AI: the ICO's strategic approach published	2026-06-04	Statement	AI processing across all sectors; automated decision-making; biometric data	AI strategy; ADM; biometrics; generative AI; ICO25; regulatory approach	0.95	f	f	0.75	https://ico.org.uk/media2/migrated/4029424/regulating-ai-the-icos-strategic-approach.pdf	\N	ICO published its strategic approach to AI regulation in response to a February 2024 request from the Secretary of State for DSIT. Strategy identified AI as a key enforcement focus for 2024-25 alongside children's privacy and ad-tech. ICO positioned itself as de facto lead AI regulator. Announced programme of consensual audits of high-risk AI use cases, particularly biometrics. Confirmed enforcement action will be taken where necessary.	2027-04-04 00:00:00+01	1	t
R2-005	ICO action taken against Sky Betting and Gaming for using cookies without consent	2025-05-09	News	Cookie processing; behavioural advertising; consent management	cookies; ad-tech; consent; online tracking; Sky Betting; gambling	0.8	f	f	0.8	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/09/action-taken-against-sky-betting-and-gaming-for-using-cookies-without-consent/	\N	ICO took enforcement action against Sky Betting and Gaming for sharing personal data via advertising cookies without consent. Sky Betting made changes in March 2023 after ICO intervention. ICO warned it was preparing to scrutinise the next 100 most frequented websites and urged all organisations to check cookie banners. Some data management platforms placed under investigation for potential PECR failures. Part of ICO's wider crackdown on ad-tech and online tracking.	2027-04-04 00:00:00+01	1	t
R2-006	ICO launches generative AI consultation series	2024-01-01	News	Generative AI training data; web scraping; purpose limitation; accuracy	generative AI; web scraping; legal basis; purpose limitation; AI training data; consultation	0.95	f	t	0.65	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/01/information-commissioner-s-office-launches-consultation-series-on-generative-ai/	\N	ICO launched a five-part consultation series on generative AI and data protection covering: legal basis for web scraping to train AI models; purpose limitation throughout the generative AI lifecycle; accuracy of training data and model outputs; further topics on rights and accountability. Consultation responses published in December 2024 warning developers they must tell people how their information is being used.	2027-04-04 00:00:00+01	1	t
R2-007	ICO publishes new fining guidance setting out how it calculates penalties	2024-01-03	News	All processing activities	fining guidance; monetary penalties; enforcement policy; penalty calculation	0.85	f	f	0.7	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/03/ico-publishes-new-fining-guidance/	\N	ICO published new fining guidance providing transparency on how it decides to issue penalties and calculate fine amounts. Publication designed to help organisations understand regulatory risk and the factors that increase or reduce penalty amounts including aggravating factors such as deliberate breach and mitigating factors such as self-reporting and cooperation.	2027-04-04 00:00:00+01	1	t
R2-008	ICO calls on 11 social media and video sharing platforms to improve children's privacy practices	2024-01-08	News	Children's data processing; social media; age assurance	children's data; Children's Code; social media; age assurance; video sharing platforms	0.9	f	f	0.75	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/08/social-media-and-video-sharing-platforms-put-on-notice-over-poor-children-s-privacy-practices/	\N	ICO wrote to 11 major social media and video sharing platforms demanding improvements to children's privacy practices. Part of ongoing enforcement of the Children's Code. ICO warned that platforms failing to comply face enforcement action. Action followed earlier interventions including the TikTok fine and Snap My AI investigation.	2027-04-04 00:00:00+01	1	t
R2-009	ICO warns Meta to pause plans to train generative AI on UK user data	2024-01-06	News	Generative AI training data; social media data; legitimate interests	generative AI; Meta; Facebook; AI training data; legitimate interests; web scraping	0.95	t	f	0.85	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/06/statement-in-response-to-metas-plans-to-train-generative-ai-with-user-data/	\N	ICO raised concerns with Meta about its plans to use UK user data from Facebook and Instagram to train generative AI models. Meta paused plans following ICO intervention. ICO stated this reflected its commitment to ensuring organisations do not use personal data for AI training without a lawful basis. Linked to broader ICO focus on generative AI and web scraping consultation.	2027-04-04 00:00:00+01	1	t
R2-010	ICO joint investigation into 23andMe data breach announced	2024-01-06	Investigation Announcement	Genetic data processing; data breach; special category data; international cooperation	23andMe; genetic data; data breach; international enforcement; special category data; CASL	0.9	t	f	0.85	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/06/ico-to-investigate-23andme-data-breach-with-canadian-counterpart/	\N	ICO announced joint investigation with the Office of the Privacy Commissioner of Canada into the October 2023 data breach at genetic testing company 23andMe which affected 155,592 UK users. Investigation reflected ICO commitment to international cooperation on cross-border data protection enforcement. Led ultimately to £2.31m fine issued in June 2025.	2027-04-04 00:00:00+01	1	t
R2-011	ICO publishes ICO 2024 year in review	2024-01-12	News	All processing activities	year in review; enforcement summary; AI; children's data; cookies; biometrics	0.8	f	f	0.6	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/12/ico-2024-a-year-in-review/	\N	ICO year in review summarising 2024 enforcement and regulatory activities. Key themes: PSNI £750k fine; Serco Leisure biometric enforcement; Meta AI intervention; 23andMe investigation launch; children's privacy platform letters; Sky Betting cookie enforcement; new fining guidance; generative AI consultation launch; Electoral Commission reprimand; water company transparency demands. ICO confirmed continuation of public sector approach to enforcement.	2027-04-04 00:00:00+01	1	t
R2-012	ICO gives clear response to Google on fingerprinting	2024-01-12	Statement	Online tracking; cookie alternatives; fingerprinting; behavioural advertising	fingerprinting; Google; ad-tech; cookies; online tracking; consent	0.85	f	f	0.8	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/12/our-response-to-google-s-policy-change-on-fingerprinting/	\N	ICO issued clear statement to Google that businesses do not have free rein to use fingerprinting to track users online. Statement followed Google's announcement of plans to use fingerprinting as an alternative tracking mechanism. ICO confirmed fingerprinting without consent is unlawful under PECR and UK GDPR and warned of enforcement consequences.	2027-04-04 00:00:00+01	1	t
R2-013	ICO launches AI and biometrics strategy	2025-05-06	Statement	AI processing; biometric data; automated decision-making; agentic AI	AI strategy; biometrics; ADM; agentic AI; transparency; bias; discrimination; recruitment	0.98	f	f	0.8	https://ico.org.uk/about-the-ico/our-information/our-strategies-and-plans/artificial-intelligence-and-biometrics-strategy/	\N	ICO launched new AI and biometrics strategy identifying three priority areas: transparency and explainability; bias and discrimination; rights and redress. Strategy committed to: consulting on ADM and profiling guidance by autumn 2025; developing a statutory code of practice on AI and ADM; increasing scrutiny of ADM in recruitment; establishing high threshold of lawfulness for emotion inference AI; ramping up focus on agentic AI risks.	2027-04-04 00:00:00+01	1	t
R2-014	ICO reprimands Electoral Commission after cyber attack	2024-01-07	News	Security processing; public sector data breach	Electoral Commission; cyber attack; security breach; public sector; reprimand	0.75	f	f	0.55	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/07/ico-reprimands-the-electoral-commission-after-cyber-attack-compromises-servers/	\N	ICO reprimanded the Electoral Commission following a cyber attack that compromised its servers and the personal data of approximately 40 million people on the electoral register. Reprimand rather than fine issued under ICO public sector enforcement approach. ICO criticised the Commission's failure to implement basic security measures including multi-factor authentication.	2027-04-04 00:00:00+01	1	t
R2-015	ICO warns all organisations they must do better to protect people following data breaches	2024-01-10	Statement	Security processing; data breach management	data breach; security; organisations must do better; Commissioner warning	0.85	f	f	0.75	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/10/ripple-effect-the-devastating-impact-of-data-breaches/	\N	Commissioner John Edwards issued stark public warning that organisations must do better to protect people's data following a series of high-profile breaches. Statement highlighted consequences of data breaches for individuals. Part of ICO's communications strategy around the PSNI fine and Capita investigation. Signals ICO intent to hold organisations to higher security standards.	2027-04-04 00:00:00+01	1	t
R2-016	ICO generative AI consultation response published	2024-01-12	News	Generative AI training; web scraping; purpose limitation; accuracy	generative AI; web scraping; consultation response; AI training data; lawful basis	0.95	f	f	0.7	https://ico.org.uk/media2/p3mkalna/our-response-to-uk-governments-consultation-on-copyright-and-artificial-intelligence.pdf	\N	ICO published response to its five-part generative AI consultation series. Key findings: developers must tell people how their information is being used; web scraping for AI training requires a lawful basis under UK GDPR; legitimate interests can potentially apply but requires careful balancing test; purpose limitation applies throughout the AI lifecycle. Guidance expected to be formally updated following passage of Data Use and Access Act.	2027-04-04 00:00:00+01	1	t
R2-017	ICO confirms public sector enforcement approach will continue	2024-01-12	Statement	Public sector data processing	public sector; enforcement approach; reprimands; fines; public bodies	0.7	f	f	0.5	https://ico.org.uk/about-the-ico/our-information/policies-and-procedures/public-sector-approach/	\N	ICO confirmed continuation of its public sector enforcement approach following a post-trial review. Approach introduced in 2022 on trial basis means ICO exercises greater discretion in setting fine levels for public bodies given that fines represent public money moving between public bodies. Private sector organisations committing identical breaches remain subject to standard fine levels.	2027-04-04 00:00:00+01	1	t
R2-018	ICO sends advisory notice to public authorities on safe FOI disclosure following PSNI breach	2023-01-09	Statement	Freedom of information; data disclosure; public sector	FOI; PSNI; safe disclosure; advisory notice; public sector	0.65	f	f	0.5	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/05/psni-facing-a-750k-fine-following-spreadsheet-error-that-exposed-the-personal-information-of-its-entire-workforce/	\N	ICO published advisory notice with recommendations for public authorities to prevent accidental personal data disclosure in FOI responses following PSNI breach. Published checklist for safe disclosure and publicised existing guidance. Signalled ICO focus on public sector data handling practices in FOI context.	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: r3_ico_consultations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r3_ico_consultations (consultation_id, title, publication_date, document_type, consultation_status, consultation_closes, processing_activities, topic_tags, topic_relevance_score, obligation_direction, enforcement_signal, follows_enforcement, source_url, rss_guid, raw_text, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
R3-001	Guidance on AI and Data Protection (updated)	2024-03-03	Guidance	Finalised	\N	AI processing; automated decision-making; fairness in AI	AI; ADM; fairness; UK GDPR; data protection by design	0.95	Clarifies	0.7	f	https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/artificial-intelligence/guidance-on-ai-and-data-protection/	\N	ICO updated its core Guidance on AI and Data Protection to clarify requirements for fairness in AI. Update made following requests from UK industry and delivers on ICO25 commitment to help organisations adopt new technologies while protecting people. Guidance supports the UK government's pro-innovation approach to AI regulation. Updated sections cover fairness as a core data protection principle in AI systems and mitigating discrimination risks.	2027-04-04 00:00:00+01	1	t
R3-002	Eight questions developers and deployers of generative AI need to ask	2023-01-04	Guidance	Finalised	\N	Generative AI development; training data; AI deployment	generative AI; eight questions; lawful basis; transparency; DPIA; AI governance	0.95	Tightens	0.65	f	https://ico.org.uk/about-the-ico/media-centre/blog-generative-ai-eight-questions-that-developers-and-users-need-to-ask/	\N	ICO published guidance setting out eight key questions that organisations developing or deploying generative AI that processes personal data must ask themselves. Questions covered: legal basis for processing; purpose limitation; data minimisation; accuracy; retention; individual rights; international transfers; and accountability. First ICO substantive guidance specifically addressing generative AI. Signalled intent to scrutinise AI developers and deployers.	2027-04-04 00:00:00+01	1	t
R3-003	Draft guidance on 'Likely to be accessed by children' under the Children's Code	2023-01-03	Consultation	Response Published	2024-07-05	Children's data processing; age assurance; online services	Children's Code; age assurance; likely to be accessed; AADC; online services	0.85	Tightens	0.65	f	https://ico.org.uk/about-the-ico/ico-and-stakeholder-consultations/2023/03/ico-consultation-on-the-draft-guidance-for-likely-to-be-accessed-in-the-context-of-the-children-s-code/	\N	ICO consulted on draft guidance clarifying when an online service is 'likely to be accessed by children' and therefore must comply with the Children's Code. Guidance clarified that self-declaration of age is unlikely to be effective where high data processing risks exist for children. Services must document their assessment and apply appropriate age assurance. Consultation closed May 2023.	2027-04-04 00:00:00+01	1	t
R3-004	Draft biometric data guidance phase one	2024-06-08	Consultation	Response Published	2024-08-10	Biometric data processing; biometric recognition systems; workplace surveillance	biometrics; facial recognition; fingerprint scanning; biometric recognition; special category data	0.9	Tightens	0.75	t	https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/lawful-basis/biometric-data-guidance-biometric-recognition/	\N	ICO published draft guidance on biometric data explaining how data protection law applies when biometric data is used in biometric recognition systems. Consultation ran for nine weeks from August to October 2023 and received 49 responses. Guidance finalised and published alongside Serco Leisure enforcement action in February 2024. Directly followed ICO investigations into biometric processing in workplaces. Tightens obligations on organisations using biometric recognition by clarifying high bar for lawful basis and necessity tests.	2027-04-04 00:00:00+01	1	t
R3-005	ICO fining guidance	2024-01-03	Guidance	Finalised	\N	All processing activities	fining guidance; monetary penalties; enforcement policy; aggravating factors; mitigating factors; penalty calculation	0.85	Clarifies	0.7	f	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/03/ico-publishes-new-fining-guidance/	\N	ICO published new fining guidance providing transparency on how it decides to issue monetary penalties and calculate fine amounts. Guidance sets out aggravating factors (deliberate breach; large scale; special category data; repeat offender; concealment) and mitigating factors (self-reporting; cooperation; prompt remediation). Important for REG-1 as it quantifies factors that determine penalty severity and gives a framework for predicting fine levels.	2027-04-04 00:00:00+01	1	t
R3-006	Call for views on the consent or pay model	2024-01-04	Call for Evidence	Response Published	2024-01-06	Consent management; online advertising; cookies; behavioural advertising	consent or pay; cookies; online advertising; legitimate interests; ad-tech; publisher model	0.85	Clarifies	0.65	f	https://ico.org.uk/about-the-ico/ico-and-stakeholder-consultations/2025/01/call-for-views-on-consent-or-pay-business-models/	\N	ICO launched call for views on its regulatory approach to the 'consent or pay' business model used by some websites (offering users a choice between paying a subscription or consenting to advertising cookies). ICO sought to determine whether this model is compatible with the requirement for freely given consent under UK GDPR. ICO subsequently indicated that many lawful alternatives exist and that consent given under a pay-or-consent model may not be freely given.	2027-04-04 00:00:00+01	1	t
R3-007	Generative AI consultation series Chapter 1: Lawful basis for web scraping	2025-03-01	Consultation	Response Published	2024-01-03	Generative AI training; web scraping; lawful basis	generative AI; web scraping; lawful basis; legitimate interests; training data; AI development	0.98	Tightens	0.75	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/response-to-the-consultation-series-on-generative-ai/the-lawful-basis-for-web-scraping-to-train-generative-ai-models/	\N	First chapter of ICO five-part generative AI consultation series. Addressed the lawful basis required to web-scrape personal data to train generative AI models. ICO indicated that legitimate interests can potentially apply but requires careful balancing test and that developers must consider whether scraping was reasonably expected by data subjects. Closed March 2024. Key document for any organisation training AI on publicly available data.	2027-04-04 00:00:00+01	1	t
R3-008	Generative AI consultation series Chapter 2: Purpose limitation	2024-01-03	Consultation	Response Published	2024-12-04	Generative AI lifecycle; purpose limitation; data reuse	generative AI; purpose limitation; compatible purpose; AI lifecycle; training data	0.95	Tightens	0.7	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/generative-ai-second-call-for-evidence/	\N	Second chapter of generative AI consultation series covering how the purpose limitation principle applies at different stages of the generative AI lifecycle from data collection through training to deployment. ICO position: original collection purpose constrains downstream use for AI training. Compatible purpose assessment required. Closed April 2024.	2027-04-04 00:00:00+01	1	t
R3-018	Guidance on AI and automated decision-making (ADM)	2025-01-10	Guidance	Open	\N	ADM; automated decisions; profiling; Article 22; solely automated processing; human review	AI; ADM; automated decision-making; Article 22; profiling; human oversight	0.98	Tightens	0.8	f	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2026/03/automated-decisions-can-streamline-the-hiring-process-with-the-right-safeguards-in-place/	\N		2027-04-04 00:00:00+01	1	t
R3-009	Generative AI consultation series Chapter 3: Accuracy	2024-01-04	Consultation	Response Published	2024-10-05	Generative AI outputs; accuracy principle; hallucination	generative AI; accuracy; hallucination; training data quality; AI outputs	0.9	Tightens	0.65	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/generative-ai-third-call-for-evidence/	\N	Third chapter of generative AI consultation series covering how the accuracy principle applies to generative AI model outputs and the impact of training data accuracy. ICO flagged concern about AI hallucination and the risk of inaccurate outputs causing harm to data subjects. Closed May 2024.	2027-04-04 00:00:00+01	1	t
R3-010	Generative AI consultation series Chapter 4: Individual rights	2024-01-05	Consultation	Response Published	2024-01-07	Generative AI; data subject rights; right to erasure; right of access	generative AI; data subject rights; right to erasure; right of access; right to rectification; AI training	0.9	Tightens	0.65	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/generative-ai-fourth-call-for-evidence/	\N	Fourth chapter of generative AI consultation series covering how data subject rights apply in the context of AI training and fine-tuning. Addressed how organisations can comply with rights to erasure and access where personal data has been used in model training. Closed July 2024.	2027-04-04 00:00:00+01	1	t
R3-011	Generative AI consultation series Chapter 5: Accountability in the AI supply chain	2024-01-07	Consultation	Response Published	2025-06-09	Generative AI supply chain; controller/processor accountability; AI governance	generative AI; accountability; supply chain; controller; processor; AI governance	0.95	Tightens	0.7	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/response-to-the-consultation-series-on-generative-ai/allocating-controllership-across-the-generative-ai-supply-chain/	\N	Fifth and final chapter of generative AI consultation series covering allocation of accountability for data protection compliance across the generative AI supply chain. Addressed how controller and processor relationships apply where AI developers provide foundation models to deployers. Closed September 2024.	2027-04-04 00:00:00+01	1	t
R3-012	Generative AI consultation series: ICO response	2024-01-12	Consultation	Response Published	\N	Generative AI; all chapters; lawful basis; purpose limitation; accuracy; rights; accountability	generative AI; consultation response; web scraping; lawful basis; purpose limitation; AI training	0.98	Tightens	0.75	f	https://ico.org.uk/about-the-ico/what-we-do/our-work-on-artificial-intelligence/response-to-the-consultation-series-on-generative-ai/	\N	ICO published consolidated response to its five-part generative AI consultation series. Key conclusions: developers must tell people how their information is being used; web scraping requires a lawful basis; legitimate interests can apply but needs careful balancing; purpose limitation applies throughout the AI lifecycle; individual rights apply even where data is embedded in model weights. Response updated ICO's core AI guidance and signalled further statutory guidance to follow.	2027-04-04 00:00:00+01	1	t
R3-013	Updated Opinion on Age Assurance for the Children's Code	2024-01-01	Opinion	Finalised	\N	Children's data; age assurance; online services; parental consent	age assurance; Children's Code; AADC; self-declaration; technical accuracy; parental consent	0.9	Tightens	0.7	f	https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2024/01/ico-publishes-updated-commissioner-s-opinion-on-age-assurance-for-the-children-s-code/	\N	ICO published updated Opinion on Age Assurance for the Children's Code reflecting developments since the original 2021 Opinion. Updated guidance clarifies that self-declaration of age is unlikely to be appropriate where platforms process children's data in high-risk ways. Organisations must adopt age assurance with appropriate technical accuracy. Takes into account Online Safety Act 2023 alignment with Ofcom requirements.	2027-04-04 00:00:00+01	1	t
R3-014	Children's Code strategy and 2024-25 priorities for social media and video sharing platforms	2024-03-04	Guidance	Finalised	\N	Children's data; social media; recommender systems; age assurance; default settings	Children's Code; social media; VSPs; SMPs; recommender systems; default settings; age assurance	0.9	Tightens	0.75	f	https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/protecting-childrens-privacy-online-our-childrens-code-strategy/children-s-code-strategy-progress-update-december-2025/	\N	ICO published Children's Code strategy setting out 2024-25 priorities for protecting children's privacy on social media and video sharing platforms. Priorities included: default privacy settings; recommender systems; age assurance; consent collection practices. ICO committed to review 34 social media and video sharing platforms and take regulatory action where needed. Led to letters to platforms, Imgur investigation, and Vero and Vimeo commitments.	2027-04-04 00:00:00+01	1	t
R3-015	Draft storage and access technologies guidance (updated cookie guidance)	2025-01-07	Consultation	Closed	2027-02-09	Cookie processing; online tracking; consent; behavioural advertising	cookies; storage and access technologies; consent; PECR; cookie guidance; online tracking	0.88	Clarifies	0.65	f	https://ico.org.uk/for-organisations/direct-marketing-and-privacy-and-electronic-communications/guidance-on-the-use-of-storage-and-access-technologies/	\N	ICO consulted on updated guidance on storage and access technologies (previously known as cookie guidance) reflecting developments in tracking technologies including fingerprinting and new ad-tech approaches. Consultation closed September 2025. Part of broader ICO response to ad-tech enforcement including Sky Betting action and Google fingerprinting warning.	2027-04-04 00:00:00+01	1	t
R3-016	Recognised legitimate interest guidance	2025-01-09	Consultation	Closed	2027-06-10	Legitimate interests processing; balancing test; public tasks	legitimate interests; balancing test; recognised legitimate interest; DUAA; Data Use and Access Act	0.85	Clarifies	0.6	f	https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/lawful-basis/recognised-legitimate-interest-detailed/	\N	ICO consulted on guidance on the new recognised legitimate interests provision introduced by the Data Use and Access Act 2025. Recognised legitimate interests is a new basis in UK law allowing certain processing without a full balancing test for specific listed purposes. Consultation closed October 2025. Key guidance for understanding post-DUAA legal landscape.	2027-04-04 00:00:00+01	1	t
R3-017	Guidance on profiling tools for online safety	2025-01-09	Consultation	Closed	2027-07-10	Profiling; online safety; recommender systems; behavioural advertising	profiling; Online Safety Act; recommender systems; online safety; children's data	0.88	Tightens	0.7	f	https://citizen-space.ico.org.uk/regulatory-risk/guidance-profiling-tools-online-safety-survey/	\N	ICO consulted on guidance on use of profiling tools for online safety purposes under data protection law. Covers how profiling can be used lawfully for safety purposes such as age assurance and content moderation in the context of the Online Safety Act 2023. Consultation closed October 2025.	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: r4_secondary_regulators; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r4_secondary_regulators (secondary_id, regulator, action_date, action_type, org_name, org_type, processing_activities, topic_tags, topic_relevance_score, cross_regulator_flag, ico_referral, enforcement_signal, source_url, rss_guid, raw_text, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
R4-001	CMA	2024-06-09	Market Study	NA	AI foundation models sector	AI foundation model development; data processing for AI training; market power in data access	AI foundation models; competition; market study; big tech; AI governance; digital markets	0.9	f	f	0.65	https://www.gov.uk/government/publications/ai-foundation-models-initial-report	\N	\N	2027-04-04 00:00:00+01	1	t
R4-002	CMA	2024-11-04	Market Study	NA	AI foundation models sector	AI foundation model development; cloud infrastructure; data access and market power	AI foundation models; competition; principles; Microsoft; Google; Amazon; cloud; AI partnerships	0.9	t	f	0.7	https://www.gov.uk/government/publications/ai-foundation-models-update-report	\N	\N	2027-04-04 00:00:00+01	1	t
R4-003	CMA	2025-04-01	Investigation	Microsoft / OpenAI partnership	Large tech / AI	AI training data access; cloud computing for AI; market power	Microsoft; OpenAI; AI partnership; merger control; foundation models; competition	0.88	f	f	0.65	https://www.gov.uk/cma-cases/microsoft-slash-openai-partnership-merger-inquiry	\N	\N	2027-04-04 00:00:00+01	1	t
R4-004	CMA	2025-07-12	Investigation	Amazon / Anthropic partnership	Large tech / AI	AI training data access; cloud infrastructure; model development	Amazon; Anthropic; AI partnership; cloud; foundation models; competition	0.88	f	f	0.65	Amazon / Anthropic partnership	\N	\N	2027-04-04 00:00:00+01	1	t
R4-005	CMA	2025-04-08	Investigation	Cloud computing providers (Amazon AWS; Microsoft Azure; Google Cloud)	Large tech / Cloud	Cloud infrastructure for AI; data processing at scale; vendor lock-in	cloud computing; AWS; Azure; Google Cloud; switching costs; market investigation; market power	0.85	f	f	0.65	https://www.gov.uk/cma-cases/cloud-services-market-investigation	\N	\N	2027-04-04 00:00:00+01	1	t
R4-006	CMA	2026-06-11	Enforcement	Multiple (StubHub; viagogo; AA Driving School; BSM; Gold's Gym; Wayfair; Appliances Direct; Marks Electrical)	Consumer / Retail / Ticketing	Online consumer data processing; consent for optional charges; pricing transparency	DMCCA; consumer protection; drip pricing; online pricing; pressure selling; dark patterns; consent	0.7	f	f	0.55	https://www.gov.uk/cma-cases/appliances-direct-consumer-protection-enforcement-case	\N	\N	2027-04-04 00:00:00+01	1	t
R4-007	CMA	2026-09-03	Guidance	NA	All sectors deploying AI agents	Automated decision-making by AI agents; consumer data use in agentic AI	agentic AI; consumer law; DMCCA; AI transparency; consumer protection; AI agents	0.92	t	f	0.7	https://www.gov.uk/government/publications/agentic-ai-and-consumers/agentic-ai-and-consumers	\N	\N	2027-04-04 00:00:00+01	1	t
R4-008	Ofcom	2025-02-10	Guidance	NA	Online platforms; user-to-user services; search services	Children's data processing; age assurance; content moderation; platform data processing	Online Safety Act; OSA; illegal content; children's safety; age assurance; duty of care	0.82	t	f	0.65	https://www.ofcom.org.uk/internet-based-services/network-neutrality/ofcom-revises-net-neutrality-guidance	\N	\N	2027-04-04 00:00:00+01	1	t
R4-009	Ofcom	2026-05-01	Enforcement	NA	Adult content providers (first wave)	Age verification data processing; children's access assessment	age assurance; adult content; Online Safety Act; pornography; HEAA; highly effective age assurance	0.82	t	f	0.75	https://www.ofcom.org.uk/online-safety/protecting-children/enforcement-programme-to-protect-children-from-encountering-pornographic-content-through-the-use-of-age-assurance	\N	\N	2027-04-04 00:00:00+01	1	t
R4-010	Ofcom	2024-08-11	Guidance	NA	Generative AI service providers; online platforms	AI chatbot data processing; user-generated content from AI; children's data on AI platforms	Online Safety Act; generative AI; chatbots; user-to-user services; OSA scope; AI regulation	0.92	t	f	0.7	https://www.ofcom.org.uk/online-safety/illegal-and-harmful-content/open-letter-to-uk-online-service-providers-regarding-generative-ai-and-chatbots	\N	\N	2027-04-04 00:00:00+01	1	t
R4-011	Ofcom	2026-05-03	Enforcement	NA	File-sharing and file-storage services	CSAM detection; user data processing for content moderation; risk assessments	Online Safety Act; CSAM; file sharing; illegal content; perceptual hash-matching; enforcement programme	0.75	f	f	0.7	https://www.ofcom.org.uk/online-safety/illegal-and-harmful-content/enforcement-programme-into-measures-being-taken-by-file-sharing-and-file-storage-services-to-prevent-users-from-encountering-or-sharing-child-sexual-abuse-material-csam	\N	\N	2027-04-04 00:00:00+01	1	t
R4-012	Ofcom	2025-01-08	Enforcement	4chan	Social media / Imageboard	Content moderation; illegal content risk assessment; user data processing	4chan; Online Safety Act; illegal content; risk assessment; enforcement; non-compliance; extraterritorial	0.72	f	f	0.65	https://www.ofcom.org.uk/online-safety/illegal-and-harmful-content/investigation-into-4chan-and-its-compliance-with-duties-to-protect-its-users-from-illegal-content	\N	\N	2027-04-04 00:00:00+01	1	t
R4-013	Ofcom	2025-01-12	Enforcement	AVS Group (Belize)	Adult content / Pornography	Age verification data processing; children's access controls	age assurance; adult content; Online Safety Act; Belize; extraterritorial enforcement; HEAA	0.78	f	f	0.65	https://www.ofcom.org.uk/online-safety/protecting-children/ofcom-fines-porn-company-1million-for-not-having-robust-age-checks#:~:text=Ofcom%20has%20today%20fined%20AVS%20Group%20Ltd,for%20failing%20to%20respond%20to%20information%20requests.	\N	\N	2027-04-04 00:00:00+01	1	t
R4-014	Ofcom	2025-01-12	Enforcement	Itai Tech Ltd (Undress.cc)	AI / Nudification	AI-generated intimate imagery; age verification; children's data protection	Itai Tech; Undress.cc; nudification; age assurance; Online Safety Act; deepfakes; AI-generated intimate images	0.88	t	f	0.8	https://www.ofcom.org.uk/online-safety/protecting-children/ofcom-fines-nudification-site-50000-for-failing-to-introduce-age-checks	\N	\N	2027-04-04 00:00:00+01	1	t
R4-015	Ofcom	2024-09-04	Guidance	NA	All sectors	AI model processing; age verification; deepfake detection; content moderation	Ofcom AI strategy; deepfakes; age assurance; Online Safety Act; DRCF cooperation; agentic AI	0.88	t	f	0.65	https://www.ofcom.org.uk/about-ofcom/annual-reports-and-plans/ofcoms-strategic-approach-to-ai	\N	\N	2027-04-04 00:00:00+01	1	t
R4-016	FCA	2023-01-11	Guidance	NA	Financial services firms using AI	AI-driven financial decisions; customer data processing; algorithmic profiling	AI in financial services; FCA; Consumer Duty; algorithmic decision-making; fair treatment; AI governance	0.8	t	f	0.6	https://www.fca.org.uk/publications/feedback-statements/fs23-4-artificial-intelligence-and-machine-learning	\N	\N	2027-04-04 00:00:00+01	1	t
R4-017	FCA	2025-07-02	Guidance	NA	Financial services firms	Customer data processing for AI-driven advice; algorithmic decision-making; fair treatment	Consumer Duty; AI; customer outcomes; fair value; AI oversight; automated advice	0.8	t	f	0.65	https://www.fca.org.uk/data/financial-promotions-data-2024	\N	\N	2027-04-04 00:00:00+01	1	t
R4-018	AI Safety Institute	2023-02-11	Guidance	NA	AI developers and deployers; frontier AI	AI model evaluation; training data; model capability assessment	AISI; AI safety; frontier AI; evaluation; red-teaming; safety testing; AI risk	0.85	f	f	0.55	https://www.gov.uk/government/publications/ai-safety-institute-approach-to-evaluations	\N	\N	2027-04-04 00:00:00+01	1	t
R4-019	AI Safety Institute	2025-09-05	Guidance	NA	Foundation model developers	AI model training and evaluation; dangerous capability assessment	AISI; AI safety testing; pre-deployment evaluation; capability thresholds; AI risk assessment	0.85	f	f	0.55	https://www.gov.uk/government/news/global-leaders-agree-to-launch-first-international-network-of-ai-safety-institutes-to-boost-understanding-of-ai	\N	\N	2027-04-04 00:00:00+01	1	t
R4-020	CMA	2025-01-01	Enforcement	NA	Digital markets; strategic market status firms	Data processing by designated platforms; data access obligations; platform data sharing	DMCCA; digital markets; strategic market status; SMS; big tech; competition regime	0.85	f	f	0.65	https://competitionandmarkets.blog.gov.uk/2025/03/10/our-new-consumer-enforcement-regime/#:~:text=Our%20new%20consumer%20enforcement%20regime,the%20new%20consumer%20protection%20regime.	\N	\N	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: r5_international_bodies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r5_international_bodies (international_id, body, jurisdiction, action_date, action_type, org_name, org_type, penalty_eur, processing_activities, topic_tags, topic_relevance_score, uk_company_involved, gdpr_articles, ico_signal_strength, source_url, gdpr_tracker_id, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
R5-001	Irish DPC	Ireland / EU	2024-10-05	Enforcement Decision	Meta Platforms Ireland Limited	Social media / Technology	1200000000.00	International data transfers; behavioural advertising; social media processing	international transfers; SCCs; Chapter V GDPR; US transfers; Facebook; Meta; EDPB binding decision	0.9	t	GDPR Article 46(1); Article 44	0.7	https://www.dataprotection.ie/en/news-media/press-releases/Data-Protection-Commission-announces-conclusion-of-inquiry-into-Meta-Ireland	\N	2027-04-04 00:00:00+01	1	t
R5-002	Irish DPC	Ireland / EU	2024-03-09	Enforcement Decision	TikTok Technology Limited	Social media / Technology	345000000.00	Children's data processing; default privacy settings; parental controls; age verification	children's data; default settings; family pairing; GDPR Article 8; children's privacy; TikTok	0.95	t	GDPR Article 5(1)(a); Article 5(1)(c); Article 5(1)(f); Article 6; Article 8; Article 12; Article 13; Article 25	0.9	https://www.dataprotection.ie/en/dpc-guidance/law/decisions-made-under-data-protection-act-2018/Inquiry-into-TikTok-Technology-Limited-September-2023	\N	2027-04-04 00:00:00+01	1	t
R5-003	Irish DPC	Ireland / EU	2024-07-01	Enforcement Decision	WhatsApp Ireland Ltd	Messaging / Technology	5500000.00	Consent management; terms of service; data sharing; transparency	consent; terms of service; Meta data sharing; transparency; lawful basis	0.8	t	GDPR Article 6; Article 7; Article 12; Article 13	0.6	https://www.dataprotection.ie/en/news-media/data-protection-commission-announces-conclusion-inquiry-whatsapp	\N	2027-04-04 00:00:00+01	1	t
R5-004	Dutch AP	Netherlands / EU	2024-04-01	Enforcement Decision	Uber Technologies Inc.; Uber B.V.	Ride-hailing / Technology	290000000.00	International data transfers; driver personal data; EU-US transfers	international transfers; EU-US; Chapter V GDPR; Uber; driver data; SCCs; Privacy Shield	0.85	t	GDPR Article 44; Article 46	0.65	https://www.edpb.europa.eu/news/news/2024/dutch-sa-imposes-fine-290-million-euro-uber-because-transfers-drivers-data-us_en	\N	2027-04-04 00:00:00+01	1	t
R5-005	Irish DPC	Ireland / EU	2025-12-10	Enforcement Decision	LinkedIn Ireland Unlimited Company	Professional networking / Technology	310000000.00	Behavioural advertising; consent management; legitimate interests; profiling	LinkedIn; behavioural advertising; consent; legitimate interests; profiling; ad targeting	0.88	t	GDPR Article 5(1)(a); Article 6(1)(a); Article 6(1)(b); Article 6(1)(f)	0.75	https://www.dataprotection.ie/en/news-media/press-releases/irish-data-protection-commission-fines-linkedin-ireland-eu310-million	\N	2027-04-04 00:00:00+01	1	t
R5-006	Irish DPC	Ireland / EU	2025-05-12	Enforcement Decision	Meta Platforms Ireland Limited	Social media / Technology	251000000.00	Security processing; data breach notification; access token vulnerability	data breach; security; access tokens; Facebook breach 2018; breach notification; Article 33	0.85	t	GDPR Article 5(1)(f); Article 32; Article 33; Article 34	0.7	https://www.dataprotection.ie/en/news-media/press-releases/irish-data-protection-commission-fines-meta-eu251-million	\N	2027-04-04 00:00:00+01	1	t
R5-007	Italian Garante	Italy / EU	2025-08-12	Enforcement Decision	OpenAI (ChatGPT)	AI / Technology	15000000.00	Generative AI; training data; legal basis; age verification; transparency	ChatGPT; generative AI; lawful basis; training data; age verification; transparency; AI enforcement	0.98	t	GDPR Article 5(1)(a); Article 6; Article 8; Article 12; Article 13; Article 17; Article 33	0.85	https://www.reuters.com/technology/italy-fines-openai-15-million-euros-over-privacy-rules-breach-2024-12-20/	\N	2027-04-04 00:00:00+01	1	t
R5-008	Irish DPC	Ireland / EU	2025-02-05	Enforcement Decision	TikTok Technology Limited	Social media / Technology	530000000.00	International data transfers; transfers to China; transparency; data storage	international transfers; China; Article 46; SCCs; data sovereignty; TikTok; geopolitical risk	0.92	t	GDPR Article 46(1); Article 13(1)(f)	0.8	https://www.dataprotection.ie/en/news-media/latest-news/irish-data-protection-commission-fines-tiktok-eu530-million-and-orders-corrective-measures-following	\N	2027-04-04 00:00:00+01	1	t
R5-009	Dutch AP	Netherlands / EU	2024-03-09	Enforcement Decision	Clearview AI Inc.	AI / Facial recognition	30500000.00	Biometric data processing; web scraping; facial recognition; AI training data	Clearview AI; biometrics; facial recognition; web scraping; AI training; special category data	0.95	t	GDPR Article 5; Article 6; Article 9; Article 14	0.85	https://www.edpb.europa.eu/news/national-news/2024/dutch-supervisory-authority-imposes-fine-clearview-because-illegal-data_en	\N	2027-04-04 00:00:00+01	1	t
R5-010	EDPB	EU	2024-01-04	Binding Opinion	Meta Platforms Ireland Limited (Facebook)	Social media / Technology	\N	International data transfers; US government surveillance; SCCs adequacy	EDPB; binding decision; Art 65; Meta; US transfers; SCCs; Privacy Shield; Schrems II	0.88	t	GDPR Article 46(1); Article 44; Article 65	0.75	https://www.edpb.europa.eu/news/news/2023/12-billion-euro-fine-facebook-result-edpb-binding-decision_en	\N	2027-04-04 00:00:00+01	1	t
R5-011	EDPB	EU	2024-01-03	Guideline		All sectors / AI developers	\N	Generative AI; personal data in AI training; data minimisation; purpose limitation	EDPB; ChatGPT task force; AI; generative AI; data protection principles	0.95	f	GDPR Article 5; Article 6; Article 9	0.7	https://www.edpb.europa.eu/system/files/2024-10/edpb_guidelines_202401_legitimateinterest_en.pdf	\N	2027-04-04 00:00:00+01	1	t
R5-012	Irish DPC	Ireland / EU	2024-08-07	Enforcement Decision	X (formerly Twitter)	Social media / Technology	\N	AI training data; user data for Grok AI; consent; legitimate interests	X; Twitter; Grok AI; AI training; consent; legitimate interests; suspension proceedings	0.97	t	GDPR Article 6; Article 9; Article 17	0.9	https://www.dataprotection.ie/en/news-media/latest-news/x-grok-ai-2024	\N	2027-04-04 00:00:00+01	1	t
R5-013	French CNIL	France / EU	2024-03-12	Enforcement Decision	Orange SA	Telecommunications	50000000.00	Email advertising; electronic marketing consent; inbox advertising	PECR equivalent; email advertising; consent; inbox ads; electronic marketing	0.8	f	GDPR Article 5(1)(a); Article 6(1)(a); French CPCE Article L.34-5	0.55	https://www.cnil.fr/en/orange-fined-50-million-euros	\N	2027-04-04 00:00:00+01	1	t
R5-014	Italian Garante	Italy / EU	2026-03-03	Enforcement Decision	Luka Inc. (Replika AI chatbot)	AI / Technology	5000000.00	AI chatbot; lawful basis; children's data; age verification; transparency	Replika; AI chatbot; lawful basis; children's data; age verification; transparency; AI enforcement	0.95	f	GDPR Article 5(1)(a); Article 6; Article 8; Article 12; Article 13	0.75	https://www.edpb.europa.eu/news/national-news/2025/ai-italian-supervisory-authority-fines-company-behind-chatbot-replika_en	\N	2027-04-04 00:00:00+01	1	t
R5-015	EDPB	EU	2025-11-05	Guideline		All sectors	\N	AI and data protection; model training; data minimisation; purpose limitation	EDPB; AI opinion; Article 29 WP; model training; data protection by design	0.95	f	GDPR Article 5; Article 6; Article 25	0.7	https://www.edpb.europa.eu/news/news/2024/edpb-opinion-ai-models-gdpr-principles-support-responsible-ai_en	\N	2027-04-04 00:00:00+01	1	t
\.


--
-- Data for Name: r6_drcf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r6_drcf (drcf_id, publication_date, document_type, title, participating_bodies, processing_activities, topic_tags, topic_relevance_score, ico_lead, enforcement_signal, coordinated_action_flag, source_url, rss_guid, raw_text, ingested_at, nlp_confidence, manually_reviewed) FROM stdin;
R6-001	2025-04-04	Work Programme	DRCF Workplan 2023/24	CMA; ICO; Ofcom; FCA	All digital processing activities; cross-regulator coordination	workplan; AI governance; children's online safety; online advertising; algorithmic transparency; DRCF priorities	0.8	f	0.5	f	https://www.drcf.org.uk/publications/work-plans/drcf-workplan-202324	\N	\N	2027-04-04 00:00:00+01	1	t
R6-002	2025-04-04	Report	DRCF Annual Report 2022/23	CMA; ICO; Ofcom; FCA	Cross-regulator digital regulation; AI auditing; age assurance; algorithmic transparency	annual report; algorithmic auditing; age assurance; children's online safety; cross-regulator	0.78	f	0.45	f	https://www.drcf.org.uk/siteassets/drcf/pdf-files/drcf-annual-report-2022-23?v=380461	\N	\N	2027-04-04 00:00:00+01	1	t
R6-003	2025-05-04	Work Programme	DRCF Workplan 2024/25	CMA; ICO; Ofcom; FCA	All digital processing activities; AI; online safety; digital identity; generative AI	workplan; generative AI; AI fairness; online safety; digital identity; AI and Digital Hub	0.85	f	0.55	f	https://www.drcf.org.uk/publications/work-plans/drcf-workplan-202425	\N	\N	2027-04-04 00:00:00+01	1	t
R6-004	2025-06-04	Report	DRCF Annual Report 2023/24	CMA; ICO; Ofcom; FCA	AI regulation; cross-regulator coordination; generative AI; age assurance	annual report; AI; generative AI; age assurance; cross-regulator; AI Digital Hub	0.82	f	0.5	f	https://www.drcf.org.uk/siteassets/drcf/pdf-files/drcf-annual-report-2023_24?v=383901	\N	\N	2027-04-04 00:00:00+01	1	t
R6-005	2025-03-04	Joint Statement	Fairness in AI: A View from the DRCF	CMA; ICO; Ofcom; FCA	AI fairness; algorithmic bias; automated decision-making; data protection; consumer protection	AI fairness; bias; discrimination; protected characteristics; fairness principles; DRCF; cross-regulator AI	0.92	f	0.65	f	https://www.drcf.org.uk/publications/blogs/fairness-in-ai-a-view-from-the-drcf	\N	\N	2027-04-04 00:00:00+01	1	t
R6-006	2025-10-04	Work Programme	DRCF AI and Digital Hub launch	CMA; ICO; Ofcom; FCA	AI innovation support; regulatory compliance for AI; cross-regulator AI advice	AI and Digital Hub; innovation support; regulatory advice; cross-regulator; generative AI; startup	0.85	f	0.55	f	https://www.drcf.org.uk/news-and-events/news/drcf-ai-and-digital-hub-launched-to-support-innovation-and-enable-economic-growth2	\N	\N	2027-04-04 00:00:00+01	1	t
R6-007	2024-09-07	Report	Consumer use and understanding of generative AI	CMA; ICO; Ofcom; FCA	Generative AI consumer processing; consumer data in AI; AI-driven advice; financial AI	generative AI; consumer understanding; AI literacy; consumer risk; AI in financial advice	0.88	f	0.55	f	https://www.drcf.org.uk/news-and-events/news/new-report-on-consumer-use-and-understanding-of-generative-ai	\N	\N	2027-04-04 00:00:00+01	1	t
R6-008	2025-04-07	Report	ICO-FCA paper on consumer attitudes towards digital assets	ICO; FCA	Digital asset data processing; consumer financial data; crypto; open finance	digital assets; crypto; open finance; consumer attitudes; ICO-FCA collaboration; financial data	0.78	t	0.55	f	https://www.drcf.org.uk/publications/papers/consumer-attitudes-on-the-risks-and-benefits-of-engaging-with-digital-assets	\N	\N	2027-04-04 00:00:00+01	1	t
R6-009	2027-04-01	Report	AI Assurance: Highlighting opportunities across DRCF regulatory regimes	CMA; ICO; Ofcom; FCA	AI assurance; AI auditing; algorithmic testing; compliance verification	AI assurance; AI auditing; third-party assurance; benchmarking; regulatory compliance; AI standards	0.9	f	0.6	f	https://www.drcf.org.uk/publications/blogs/ai-assurance-highlighting-opportunities-across-drcf-regulatory-regimes	\N	\N	2027-04-04 00:00:00+01	1	t
R6-010	2026-05-07	Report	The Future of Open Finance and Smart Data: Joint Insights from the FCA and ICO	ICO; FCA	Open finance data processing; smart data; consumer financial data; data portability	open finance; smart data; data portability; DUAA; consumer financial data; ICO-FCA	0.8	t	0.55	f	https://www.drcf.org.uk/publications/blogs/the-future-of-open-finance-and-smart-data-joint-insights-from-the-fca-and-ico	\N	\N	2027-04-04 00:00:00+01	1	t
R6-011	2025-05-08	Work Programme	DRCF Workplan 2025/26	CMA; ICO; Ofcom; FCA	All digital processing activities; agentic AI; synthetic media; cybersecurity; open finance	workplan; agentic AI; synthetic media; deepfakes; cybersecurity; open finance; digital regulatory library	0.88	f	0.6	f	https://www.drcf.org.uk/siteassets/drcf/pdf-files/drcf-workplan-2025_26.pdf?v=395939	\N	\N	2027-04-04 00:00:00+01	1	t
R6-012	2025-05-08	Report	DRCF Annual Report 2024/25	CMA; ICO; Ofcom; FCA	AI regulation; agentic AI; AI and Digital Hub; cross-regulator coordination	annual report; agentic AI; AI Digital Hub; AI assurance; synthetic media; cross-regulator	0.85	f	0.55	f	https://www.drcf.org.uk/siteassets/drcf/pdf-files/drcf-annual-report-202425.pdf?v=399831	\N	\N	2027-04-04 00:00:00+01	1	t
R6-013	2025-10-10	Call for Evidence	Call for Views: Agentic AI and Regulatory Challenges	CMA; ICO; Ofcom; FCA	Agentic AI processing; autonomous AI decision-making; AI agents; automated action	agentic AI; autonomous AI; call for views; regulatory challenges; cross-regulator; Thematic Innovation Hub	0.95	f	0.7	f	https://www.drcf.org.uk/news-and-events/news/call-for-views-agentic-ai-and-regulatory-challenges	\N	\N	2027-04-04 00:00:00+01	1	t
R6-014	2026-12-10	Report	DRCF Future of Cybersecurity and Emerging Technologies	CMA; ICO; Ofcom; FCA	Cybersecurity data processing; AI security; critical infrastructure data	cybersecurity; emerging technologies; AI security; resilience; horizon scanning; DRCF	0.78	f	0.5	f	https://www.drcf.org.uk/news-and-events/events/drcf-future-of-cybersecurity-and-emerging-technologies-october-2025	\N	\N	2027-04-04 00:00:00+01	1	t
R6-015	2026-02-11	Report	The Future of Synthetic Media	CMA; ICO; Ofcom; FCA	Synthetic media processing; deepfakes; AI-generated content; age assurance for synthetic content	synthetic media; deepfakes; AI-generated content; NCII; non-consensual intimate images; children's safety	0.9	f	0.65	t	https://www.google.com/search?q=The+Future+of+Synthetic+Media+2025&sca_esv=27fdc1d65c2ac978&sxsrf=ANbL-n7oibDUuZoYEVJ1b3rwiGiH3B6MlA%3A1776434981797&ei=JT_iaaelMOS1hbIPwrTMmQE&ved=0ahUKEwjny7mAiPWTAxXkWkEAHUIaMxMQ4dUDCBE&uact=5&oq=The+Future+of+Synthetic+Media+2025&gs_lp=Egxnd3Mtd2l6LXNlcnAiIlRoZSBGdXR1cmUgb2YgU3ludGhldGljIE1lZGlhIDIwMjUyBRAhGKABMgUQIRigATIFECEYoAEyBRAhGKABSL8OUKoEWMYNcAJ4AJABAJgBuwOgAbALqgEJMi4yLjEuMS4xuAEDyAEA-AEBmAIIoALuCsICChAAGEcY1gQYsAPCAgYQABgWGB7CAgsQABiABBiKBRiGA8ICBRAAGO8FwgIIEAAYgAQYogSYAwCIBgGQBgiSBwk0LjEuMS4xLjGgB8cbsgcJMi4xLjEuMS4xuAfkCsIHBTAuNi4yyAcUgAgB&sclient=gws-wiz-serp	\N	\N	2027-04-04 00:00:00+01	1	t
R6-016	2028-07-03	Work Programme	DRCF Thematic Innovation Hub: Agentic AI foresight paper and next steps	CMA; ICO; Ofcom; FCA	Agentic AI processing; automated AI actions; AI agent data use; agentic systems	agentic AI; foresight paper; Thematic Innovation Hub; regulatory guidance; cross-regulator; consumer protection	0.95	f	0.7	t	https://www.drcf.org.uk/siteassets/drcf/pdf-files/drcf-the-future-of-agentic-ai-foresight-paper.pdf?v=415481	\N	\N	2027-04-04 00:00:00+01	1	t
\.


--
-- Name: ers_component_scores ers_component_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ers_component_scores
    ADD CONSTRAINT ers_component_scores_pkey PRIMARY KEY (score_id);


--
-- Name: ers_composite_scores ers_composite_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ers_composite_scores
    ADD CONSTRAINT ers_composite_scores_pkey PRIMARY KEY (composite_id);


--
-- Name: i1_volume_statistics i1_volume_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i1_volume_statistics
    ADD CONSTRAINT i1_volume_statistics_pkey PRIMARY KEY (stat_id);


--
-- Name: i2_volume_scores i2_volume_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i2_volume_scores
    ADD CONSTRAINT i2_volume_scores_pkey PRIMARY KEY (score_id);


--
-- Name: j1_supreme_court j1_supreme_court_neutral_citation_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j1_supreme_court
    ADD CONSTRAINT j1_supreme_court_neutral_citation_key UNIQUE (neutral_citation);


--
-- Name: j1_supreme_court j1_supreme_court_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j1_supreme_court
    ADD CONSTRAINT j1_supreme_court_pkey PRIMARY KEY (supreme_id);


--
-- Name: j2_court_of_appeal j2_court_of_appeal_neutral_citation_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j2_court_of_appeal
    ADD CONSTRAINT j2_court_of_appeal_neutral_citation_key UNIQUE (neutral_citation);


--
-- Name: j2_court_of_appeal j2_court_of_appeal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j2_court_of_appeal
    ADD CONSTRAINT j2_court_of_appeal_pkey PRIMARY KEY (appeal_id);


--
-- Name: j3_information_rights_tribunal j3_information_rights_tribunal_case_reference_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j3_information_rights_tribunal
    ADD CONSTRAINT j3_information_rights_tribunal_case_reference_key UNIQUE (case_reference);


--
-- Name: j3_information_rights_tribunal j3_information_rights_tribunal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j3_information_rights_tribunal
    ADD CONSTRAINT j3_information_rights_tribunal_pkey PRIMARY KEY (tribunal_id);


--
-- Name: j4_high_court j4_high_court_neutral_citation_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j4_high_court
    ADD CONSTRAINT j4_high_court_neutral_citation_key UNIQUE (neutral_citation);


--
-- Name: j4_high_court j4_high_court_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.j4_high_court
    ADD CONSTRAINT j4_high_court_pkey PRIMARY KEY (highcourt_id);


--
-- Name: l1_bills_in_parliament l1_bills_in_parliament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l1_bills_in_parliament
    ADD CONSTRAINT l1_bills_in_parliament_pkey PRIMARY KEY (bill_id);


--
-- Name: l1_bills_in_parliament l1_bills_in_parliament_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l1_bills_in_parliament
    ADD CONSTRAINT l1_bills_in_parliament_rss_guid_key UNIQUE (rss_guid);


--
-- Name: l2_statutory_instruments l2_statutory_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l2_statutory_instruments
    ADD CONSTRAINT l2_statutory_instruments_pkey PRIMARY KEY (si_id);


--
-- Name: l2_statutory_instruments l2_statutory_instruments_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l2_statutory_instruments
    ADD CONSTRAINT l2_statutory_instruments_rss_guid_key UNIQUE (rss_guid);


--
-- Name: l2_statutory_instruments l2_statutory_instruments_si_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l2_statutory_instruments
    ADD CONSTRAINT l2_statutory_instruments_si_number_key UNIQUE (si_number);


--
-- Name: m1_ngo_activity m1_ngo_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.m1_ngo_activity
    ADD CONSTRAINT m1_ngo_activity_pkey PRIMARY KEY (ngo_activity_id);


--
-- Name: m2_media_press m2_media_press_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.m2_media_press
    ADD CONSTRAINT m2_media_press_pkey PRIMARY KEY (press_id);


--
-- Name: p1_government_speeches p1_government_speeches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p1_government_speeches
    ADD CONSTRAINT p1_government_speeches_pkey PRIMARY KEY (speech_id);


--
-- Name: p1_government_speeches p1_government_speeches_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p1_government_speeches
    ADD CONSTRAINT p1_government_speeches_rss_guid_key UNIQUE (rss_guid);


--
-- Name: p2_party_manifestos p2_party_manifestos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p2_party_manifestos
    ADD CONSTRAINT p2_party_manifestos_pkey PRIMARY KEY (manifesto_id);


--
-- Name: p3_budget_documents p3_budget_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p3_budget_documents
    ADD CONSTRAINT p3_budget_documents_pkey PRIMARY KEY (budget_id);


--
-- Name: p4_electoral_signals p4_electoral_signals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p4_electoral_signals
    ADD CONSTRAINT p4_electoral_signals_pkey PRIMARY KEY (electoral_id);


--
-- Name: p5_social_listening p5_social_listening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p5_social_listening
    ADD CONSTRAINT p5_social_listening_pkey PRIMARY KEY (social_id);


--
-- Name: p5_social_listening p5_social_listening_post_id_platform_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p5_social_listening
    ADD CONSTRAINT p5_social_listening_post_id_platform_key UNIQUE (post_id_platform);


--
-- Name: p6_parliamentary_qa p6_parliamentary_qa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p6_parliamentary_qa
    ADD CONSTRAINT p6_parliamentary_qa_pkey PRIMARY KEY (pqa_id);


--
-- Name: p6_parliamentary_qa p6_parliamentary_qa_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.p6_parliamentary_qa
    ADD CONSTRAINT p6_parliamentary_qa_rss_guid_key UNIQUE (rss_guid);


--
-- Name: r1_enforcement_register r1_enforcement_register_ico_reference_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r1_enforcement_register
    ADD CONSTRAINT r1_enforcement_register_ico_reference_key UNIQUE (ico_reference);


--
-- Name: r1_enforcement_register r1_enforcement_register_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r1_enforcement_register
    ADD CONSTRAINT r1_enforcement_register_pkey PRIMARY KEY (enforcement_id);


--
-- Name: r2_ico_news r2_ico_news_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r2_ico_news
    ADD CONSTRAINT r2_ico_news_pkey PRIMARY KEY (news_id);


--
-- Name: r2_ico_news r2_ico_news_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r2_ico_news
    ADD CONSTRAINT r2_ico_news_rss_guid_key UNIQUE (rss_guid);


--
-- Name: r3_ico_consultations r3_ico_consultations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r3_ico_consultations
    ADD CONSTRAINT r3_ico_consultations_pkey PRIMARY KEY (consultation_id);


--
-- Name: r3_ico_consultations r3_ico_consultations_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r3_ico_consultations
    ADD CONSTRAINT r3_ico_consultations_rss_guid_key UNIQUE (rss_guid);


--
-- Name: r4_secondary_regulators r4_secondary_regulators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r4_secondary_regulators
    ADD CONSTRAINT r4_secondary_regulators_pkey PRIMARY KEY (secondary_id);


--
-- Name: r4_secondary_regulators r4_secondary_regulators_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r4_secondary_regulators
    ADD CONSTRAINT r4_secondary_regulators_rss_guid_key UNIQUE (rss_guid);


--
-- Name: r5_international_bodies r5_international_bodies_gdpr_tracker_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r5_international_bodies
    ADD CONSTRAINT r5_international_bodies_gdpr_tracker_id_key UNIQUE (gdpr_tracker_id);


--
-- Name: r5_international_bodies r5_international_bodies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r5_international_bodies
    ADD CONSTRAINT r5_international_bodies_pkey PRIMARY KEY (international_id);


--
-- Name: r6_drcf r6_drcf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r6_drcf
    ADD CONSTRAINT r6_drcf_pkey PRIMARY KEY (drcf_id);


--
-- Name: r6_drcf r6_drcf_rss_guid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r6_drcf
    ADD CONSTRAINT r6_drcf_rss_guid_key UNIQUE (rss_guid);


--
-- Name: ix_ers_component_scores_component; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_component_scores_component ON public.ers_component_scores USING btree (component);


--
-- Name: ix_ers_component_scores_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_component_scores_entity_id ON public.ers_component_scores USING btree (entity_id);


--
-- Name: ix_ers_component_scores_entity_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_component_scores_entity_type ON public.ers_component_scores USING btree (entity_type);


--
-- Name: ix_ers_component_scores_window_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_component_scores_window_end ON public.ers_component_scores USING btree (window_end);


--
-- Name: ix_ers_composite_scores_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_composite_scores_entity_id ON public.ers_composite_scores USING btree (entity_id);


--
-- Name: ix_ers_composite_scores_entity_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_composite_scores_entity_type ON public.ers_composite_scores USING btree (entity_type);


--
-- Name: ix_ers_composite_scores_window_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ers_composite_scores_window_end ON public.ers_composite_scores USING btree (window_end);


--
-- Name: ix_i1_volume_statistics_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_i1_volume_statistics_manually_reviewed ON public.i1_volume_statistics USING btree (manually_reviewed);


--
-- Name: ix_i1_volume_statistics_period_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_i1_volume_statistics_period_end ON public.i1_volume_statistics USING btree (period_end);


--
-- Name: ix_i1_volume_statistics_period_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_i1_volume_statistics_period_start ON public.i1_volume_statistics USING btree (period_start);


--
-- Name: ix_i2_volume_scores_ico_sector; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_i2_volume_scores_ico_sector ON public.i2_volume_scores USING btree (ico_sector);


--
-- Name: ix_j1_supreme_court_ai_specific; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_ai_specific ON public.j1_supreme_court USING btree (ai_specific);


--
-- Name: ix_j1_supreme_court_appellant_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_appellant_type ON public.j1_supreme_court USING btree (appellant_type);


--
-- Name: ix_j1_supreme_court_decision_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_decision_date ON public.j1_supreme_court USING btree (decision_date);


--
-- Name: ix_j1_supreme_court_ico_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_ico_role ON public.j1_supreme_court USING btree (ico_role);


--
-- Name: ix_j1_supreme_court_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_manually_reviewed ON public.j1_supreme_court USING btree (manually_reviewed);


--
-- Name: ix_j1_supreme_court_outcome_direction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_outcome_direction ON public.j1_supreme_court USING btree (outcome_direction);


--
-- Name: ix_j1_supreme_court_respondent_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_respondent_type ON public.j1_supreme_court USING btree (respondent_type);


--
-- Name: ix_j1_supreme_court_restricts_ico_powers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_restricts_ico_powers ON public.j1_supreme_court USING btree (restricts_ico_powers);


--
-- Name: ix_j1_supreme_court_widens_controller_liability; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j1_supreme_court_widens_controller_liability ON public.j1_supreme_court USING btree (widens_controller_liability);


--
-- Name: ix_j2_court_of_appeal_ai_specific; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_ai_specific ON public.j2_court_of_appeal USING btree (ai_specific);


--
-- Name: ix_j2_court_of_appeal_appellant_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_appellant_type ON public.j2_court_of_appeal USING btree (appellant_type);


--
-- Name: ix_j2_court_of_appeal_decision_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_decision_date ON public.j2_court_of_appeal USING btree (decision_date);


--
-- Name: ix_j2_court_of_appeal_ico_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_ico_role ON public.j2_court_of_appeal USING btree (ico_role);


--
-- Name: ix_j2_court_of_appeal_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_manually_reviewed ON public.j2_court_of_appeal USING btree (manually_reviewed);


--
-- Name: ix_j2_court_of_appeal_outcome_direction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_outcome_direction ON public.j2_court_of_appeal USING btree (outcome_direction);


--
-- Name: ix_j2_court_of_appeal_respondent_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_respondent_type ON public.j2_court_of_appeal USING btree (respondent_type);


--
-- Name: ix_j2_court_of_appeal_restricts_ico_powers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_restricts_ico_powers ON public.j2_court_of_appeal USING btree (restricts_ico_powers);


--
-- Name: ix_j2_court_of_appeal_widens_controller_liability; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j2_court_of_appeal_widens_controller_liability ON public.j2_court_of_appeal USING btree (widens_controller_liability);


--
-- Name: ix_j3_information_rights_tribunal_ai_specific; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_ai_specific ON public.j3_information_rights_tribunal USING btree (ai_specific);


--
-- Name: ix_j3_information_rights_tribunal_appellant_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_appellant_type ON public.j3_information_rights_tribunal USING btree (appellant_type);


--
-- Name: ix_j3_information_rights_tribunal_case_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_case_type ON public.j3_information_rights_tribunal USING btree (case_type);


--
-- Name: ix_j3_information_rights_tribunal_decision_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_decision_date ON public.j3_information_rights_tribunal USING btree (decision_date);


--
-- Name: ix_j3_information_rights_tribunal_ico_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_ico_role ON public.j3_information_rights_tribunal USING btree (ico_role);


--
-- Name: ix_j3_information_rights_tribunal_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_manually_reviewed ON public.j3_information_rights_tribunal USING btree (manually_reviewed);


--
-- Name: ix_j3_information_rights_tribunal_outcome_direction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_outcome_direction ON public.j3_information_rights_tribunal USING btree (outcome_direction);


--
-- Name: ix_j3_information_rights_tribunal_tier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j3_information_rights_tribunal_tier ON public.j3_information_rights_tribunal USING btree (tier);


--
-- Name: ix_j4_high_court_ai_specific; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_ai_specific ON public.j4_high_court USING btree (ai_specific);


--
-- Name: ix_j4_high_court_case_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_case_type ON public.j4_high_court USING btree (case_type);


--
-- Name: ix_j4_high_court_decision_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_decision_date ON public.j4_high_court USING btree (decision_date);


--
-- Name: ix_j4_high_court_ico_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_ico_role ON public.j4_high_court USING btree (ico_role);


--
-- Name: ix_j4_high_court_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_manually_reviewed ON public.j4_high_court USING btree (manually_reviewed);


--
-- Name: ix_j4_high_court_outcome_direction; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_outcome_direction ON public.j4_high_court USING btree (outcome_direction);


--
-- Name: ix_j4_high_court_restricts_ico_powers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_restricts_ico_powers ON public.j4_high_court USING btree (restricts_ico_powers);


--
-- Name: ix_j4_high_court_widens_controller_liability; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_j4_high_court_widens_controller_liability ON public.j4_high_court USING btree (widens_controller_liability);


--
-- Name: ix_l1_bills_in_parliament_affects_ico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_affects_ico ON public.l1_bills_in_parliament USING btree (affects_ico);


--
-- Name: ix_l1_bills_in_parliament_bill_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_bill_status ON public.l1_bills_in_parliament USING btree (bill_status);


--
-- Name: ix_l1_bills_in_parliament_event_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_event_date ON public.l1_bills_in_parliament USING btree (event_date);


--
-- Name: ix_l1_bills_in_parliament_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_manually_reviewed ON public.l1_bills_in_parliament USING btree (manually_reviewed);


--
-- Name: ix_l1_bills_in_parliament_parliament_bill_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_parliament_bill_id ON public.l1_bills_in_parliament USING btree (parliament_bill_id);


--
-- Name: ix_l1_bills_in_parliament_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l1_bills_in_parliament_relevance_score ON public.l1_bills_in_parliament USING btree (relevance_score);


--
-- Name: ix_l2_statutory_instruments_affects_ico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_affects_ico ON public.l2_statutory_instruments USING btree (affects_ico);


--
-- Name: ix_l2_statutory_instruments_force_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_force_date ON public.l2_statutory_instruments USING btree (force_date);


--
-- Name: ix_l2_statutory_instruments_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_manually_reviewed ON public.l2_statutory_instruments USING btree (manually_reviewed);


--
-- Name: ix_l2_statutory_instruments_parent_act_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_parent_act_id ON public.l2_statutory_instruments USING btree (parent_act_id);


--
-- Name: ix_l2_statutory_instruments_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_relevance_score ON public.l2_statutory_instruments USING btree (relevance_score);


--
-- Name: ix_l2_statutory_instruments_si_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_l2_statutory_instruments_si_status ON public.l2_statutory_instruments USING btree (si_status);


--
-- Name: ix_m1_ngo_activity_activity_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_activity_type ON public.m1_ngo_activity USING btree (activity_type);


--
-- Name: ix_m1_ngo_activity_enforcement_stance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_enforcement_stance ON public.m1_ngo_activity USING btree (enforcement_stance);


--
-- Name: ix_m1_ngo_activity_formal_complaint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_formal_complaint ON public.m1_ngo_activity USING btree (formal_complaint);


--
-- Name: ix_m1_ngo_activity_ico_named; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_ico_named ON public.m1_ngo_activity USING btree (ico_named);


--
-- Name: ix_m1_ngo_activity_legal_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_legal_action ON public.m1_ngo_activity USING btree (legal_action);


--
-- Name: ix_m1_ngo_activity_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_manually_reviewed ON public.m1_ngo_activity USING btree (manually_reviewed);


--
-- Name: ix_m1_ngo_activity_ngo_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_ngo_name ON public.m1_ngo_activity USING btree (ngo_name);


--
-- Name: ix_m1_ngo_activity_publication_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_publication_date ON public.m1_ngo_activity USING btree (publication_date);


--
-- Name: ix_m1_ngo_activity_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m1_ngo_activity_topic_relevance_score ON public.m1_ngo_activity USING btree (topic_relevance_score);


--
-- Name: ix_m2_media_press_enforcement_stance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_enforcement_stance ON public.m2_media_press USING btree (enforcement_stance);


--
-- Name: ix_m2_media_press_ico_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_ico_action ON public.m2_media_press USING btree (ico_action);


--
-- Name: ix_m2_media_press_ico_mentioned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_ico_mentioned ON public.m2_media_press USING btree (ico_mentioned);


--
-- Name: ix_m2_media_press_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_manually_reviewed ON public.m2_media_press USING btree (manually_reviewed);


--
-- Name: ix_m2_media_press_outlet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_outlet ON public.m2_media_press USING btree (outlet);


--
-- Name: ix_m2_media_press_publication_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_publication_date ON public.m2_media_press USING btree (publication_date);


--
-- Name: ix_m2_media_press_story_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_story_type ON public.m2_media_press USING btree (story_type);


--
-- Name: ix_m2_media_press_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_m2_media_press_topic_relevance_score ON public.m2_media_press USING btree (topic_relevance_score);


--
-- Name: ix_p1_government_speeches_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p1_government_speeches_department ON public.p1_government_speeches USING btree (department);


--
-- Name: ix_p1_government_speeches_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p1_government_speeches_manually_reviewed ON public.p1_government_speeches USING btree (manually_reviewed);


--
-- Name: ix_p1_government_speeches_regulatory_stance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p1_government_speeches_regulatory_stance ON public.p1_government_speeches USING btree (regulatory_stance);


--
-- Name: ix_p1_government_speeches_speech_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p1_government_speeches_speech_date ON public.p1_government_speeches USING btree (speech_date);


--
-- Name: ix_p1_government_speeches_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p1_government_speeches_topic_relevance_score ON public.p1_government_speeches USING btree (topic_relevance_score);


--
-- Name: ix_p2_party_manifestos_election_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p2_party_manifestos_election_year ON public.p2_party_manifestos USING btree (election_year);


--
-- Name: ix_p2_party_manifestos_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p2_party_manifestos_manually_reviewed ON public.p2_party_manifestos USING btree (manually_reviewed);


--
-- Name: ix_p2_party_manifestos_party; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p2_party_manifestos_party ON public.p2_party_manifestos USING btree (party);


--
-- Name: ix_p3_budget_documents_budget_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p3_budget_documents_budget_year ON public.p3_budget_documents USING btree (budget_year);


--
-- Name: ix_p3_budget_documents_ico_budget_flag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p3_budget_documents_ico_budget_flag ON public.p3_budget_documents USING btree (ico_budget_flag);


--
-- Name: ix_p3_budget_documents_item_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p3_budget_documents_item_type ON public.p3_budget_documents USING btree (item_type);


--
-- Name: ix_p3_budget_documents_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p3_budget_documents_manually_reviewed ON public.p3_budget_documents USING btree (manually_reviewed);


--
-- Name: ix_p4_electoral_signals_gov_change_12m; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p4_electoral_signals_gov_change_12m ON public.p4_electoral_signals USING btree (gov_change_12m);


--
-- Name: ix_p4_electoral_signals_record_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p4_electoral_signals_record_date ON public.p4_electoral_signals USING btree (record_date);


--
-- Name: ix_p5_social_listening_account_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_account_category ON public.p5_social_listening USING btree (account_category);


--
-- Name: ix_p5_social_listening_account_handle; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_account_handle ON public.p5_social_listening USING btree (account_handle);


--
-- Name: ix_p5_social_listening_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_manually_reviewed ON public.p5_social_listening USING btree (manually_reviewed);


--
-- Name: ix_p5_social_listening_party; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_party ON public.p5_social_listening USING btree (party);


--
-- Name: ix_p5_social_listening_post_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_post_date ON public.p5_social_listening USING btree (post_date);


--
-- Name: ix_p5_social_listening_regulatory_stance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_regulatory_stance ON public.p5_social_listening USING btree (regulatory_stance);


--
-- Name: ix_p5_social_listening_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p5_social_listening_topic_relevance_score ON public.p5_social_listening USING btree (topic_relevance_score);


--
-- Name: ix_p6_parliamentary_qa_answer_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p6_parliamentary_qa_answer_date ON public.p6_parliamentary_qa USING btree (answer_date);


--
-- Name: ix_p6_parliamentary_qa_ico_mentioned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p6_parliamentary_qa_ico_mentioned ON public.p6_parliamentary_qa USING btree (ico_mentioned);


--
-- Name: ix_p6_parliamentary_qa_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p6_parliamentary_qa_manually_reviewed ON public.p6_parliamentary_qa USING btree (manually_reviewed);


--
-- Name: ix_p6_parliamentary_qa_question_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p6_parliamentary_qa_question_date ON public.p6_parliamentary_qa USING btree (question_date);


--
-- Name: ix_p6_parliamentary_qa_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_p6_parliamentary_qa_topic_relevance_score ON public.p6_parliamentary_qa USING btree (topic_relevance_score);


--
-- Name: ix_r1_enforcement_register_action_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r1_enforcement_register_action_date ON public.r1_enforcement_register USING btree (action_date);


--
-- Name: ix_r1_enforcement_register_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r1_enforcement_register_action_type ON public.r1_enforcement_register USING btree (action_type);


--
-- Name: ix_r1_enforcement_register_ai_specific; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r1_enforcement_register_ai_specific ON public.r1_enforcement_register USING btree (ai_specific);


--
-- Name: ix_r1_enforcement_register_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r1_enforcement_register_manually_reviewed ON public.r1_enforcement_register USING btree (manually_reviewed);


--
-- Name: ix_r1_enforcement_register_severity_tier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r1_enforcement_register_severity_tier ON public.r1_enforcement_register USING btree (severity_tier);


--
-- Name: ix_r2_ico_news_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r2_ico_news_manually_reviewed ON public.r2_ico_news USING btree (manually_reviewed);


--
-- Name: ix_r2_ico_news_publication_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r2_ico_news_publication_date ON public.r2_ico_news USING btree (publication_date);


--
-- Name: ix_r2_ico_news_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r2_ico_news_topic_relevance_score ON public.r2_ico_news USING btree (topic_relevance_score);


--
-- Name: ix_r3_ico_consultations_consultation_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r3_ico_consultations_consultation_status ON public.r3_ico_consultations USING btree (consultation_status);


--
-- Name: ix_r3_ico_consultations_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r3_ico_consultations_manually_reviewed ON public.r3_ico_consultations USING btree (manually_reviewed);


--
-- Name: ix_r3_ico_consultations_publication_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r3_ico_consultations_publication_date ON public.r3_ico_consultations USING btree (publication_date);


--
-- Name: ix_r3_ico_consultations_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r3_ico_consultations_topic_relevance_score ON public.r3_ico_consultations USING btree (topic_relevance_score);


--
-- Name: ix_r4_secondary_regulators_action_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_action_date ON public.r4_secondary_regulators USING btree (action_date);


--
-- Name: ix_r4_secondary_regulators_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_action_type ON public.r4_secondary_regulators USING btree (action_type);


--
-- Name: ix_r4_secondary_regulators_cross_regulator_flag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_cross_regulator_flag ON public.r4_secondary_regulators USING btree (cross_regulator_flag);


--
-- Name: ix_r4_secondary_regulators_ico_referral; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_ico_referral ON public.r4_secondary_regulators USING btree (ico_referral);


--
-- Name: ix_r4_secondary_regulators_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_manually_reviewed ON public.r4_secondary_regulators USING btree (manually_reviewed);


--
-- Name: ix_r4_secondary_regulators_regulator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_regulator ON public.r4_secondary_regulators USING btree (regulator);


--
-- Name: ix_r4_secondary_regulators_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r4_secondary_regulators_topic_relevance_score ON public.r4_secondary_regulators USING btree (topic_relevance_score);


--
-- Name: ix_r5_international_bodies_action_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_action_date ON public.r5_international_bodies USING btree (action_date);


--
-- Name: ix_r5_international_bodies_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_action_type ON public.r5_international_bodies USING btree (action_type);


--
-- Name: ix_r5_international_bodies_body; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_body ON public.r5_international_bodies USING btree (body);


--
-- Name: ix_r5_international_bodies_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_manually_reviewed ON public.r5_international_bodies USING btree (manually_reviewed);


--
-- Name: ix_r5_international_bodies_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_topic_relevance_score ON public.r5_international_bodies USING btree (topic_relevance_score);


--
-- Name: ix_r5_international_bodies_uk_company_involved; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r5_international_bodies_uk_company_involved ON public.r5_international_bodies USING btree (uk_company_involved);


--
-- Name: ix_r6_drcf_coordinated_action_flag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_coordinated_action_flag ON public.r6_drcf USING btree (coordinated_action_flag);


--
-- Name: ix_r6_drcf_document_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_document_type ON public.r6_drcf USING btree (document_type);


--
-- Name: ix_r6_drcf_ico_lead; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_ico_lead ON public.r6_drcf USING btree (ico_lead);


--
-- Name: ix_r6_drcf_manually_reviewed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_manually_reviewed ON public.r6_drcf USING btree (manually_reviewed);


--
-- Name: ix_r6_drcf_publication_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_publication_date ON public.r6_drcf USING btree (publication_date);


--
-- Name: ix_r6_drcf_topic_relevance_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_r6_drcf_topic_relevance_score ON public.r6_drcf USING btree (topic_relevance_score);


--
-- Name: l2_statutory_instruments l2_statutory_instruments_parent_act_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.l2_statutory_instruments
    ADD CONSTRAINT l2_statutory_instruments_parent_act_id_fkey FOREIGN KEY (parent_act_id) REFERENCES public.l1_bills_in_parliament(bill_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict uI1oaOjBZClbvE0p7cfIPnIzN6XQKapQ6QwDj8u6vigCE1JL8OT1ZOrjOdtGpCK

