"""
load_csvs.py — ERS Robust CSV Loader
======================================
Run from your project root (where load_csvs.py, ers_scoring.py,
the models/ folder, and the 'historical data/' folder all live).

Usage:
    python load_csvs.py              # load all tables
    python load_csvs.py --table r1  # load only tables starting with r1
    python load_csvs.py --truncate  # clear tables before loading
"""

from __future__ import annotations
import argparse, os, sys, uuid
from pathlib import Path
from datetime import datetime

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

# ── Paths ─────────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).parent
MODELS_DIR = SCRIPT_DIR / 'models'
DATA_DIR   = SCRIPT_DIR / 'historical data'

# Add models/ folder to path
for p in [str(MODELS_DIR), str(SCRIPT_DIR)]:
    if p not in sys.path:
        sys.path.insert(0, p)

# ── Import models ─────────────────────────────────────────────────────────────

try:
    from legislative_models import engine, create_tables as create_leg
    from regulatory_models  import create_tables as create_reg
    from judicial_models    import create_tables as create_jud
    from political_models   import create_tables as create_pol
    from ico_volume_models  import create_tables as create_ico
    from media_models       import create_tables as create_med
except ImportError as e:
    print(f"\u2717 Could not import models: {e}")
    print(f"  Looked in: {MODELS_DIR}")
    print(f"  Make sure your model files are inside a 'models/' subfolder.")
    sys.exit(1)

# ── Value cleaners ────────────────────────────────────────────────────────────

def parse_date(v):
    if pd.isna(v) or str(v).strip() in ('', 'None', 'nan', 'NaT'):
        return None
    s = str(v).strip()
    for fmt in ('%Y-%m-%d','%d/%m/%Y','%m/%d/%Y','%m/%d/%y',
                '%d-%m-%Y','%Y/%m/%d','%d %b %Y','%d %B %Y'):
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            continue
    try:
        return pd.to_datetime(s, dayfirst=False).date()
    except Exception:
        return None

def parse_bool(v):
    if pd.isna(v): return None
    return str(v).strip().lower() in ('true','1','yes','t')

def ensure_uuid(v):
    if pd.isna(v) or str(v).strip() in ('','None','nan'):
        return str(uuid.uuid4())
    return str(v).strip()

def clean_str(v):
    if pd.isna(v): return None
    s = str(v).strip()
    return None if s in ('','None','nan','NaT','NULL') else s

def norm_department(v):
    if pd.isna(v): return 'Other'
    MAP = {
        "prime minister's office":'Cabinet Office', 'prime ministers office':'Cabinet Office',
        'no.10':'Cabinet Office', 'no10':'Cabinet Office',
        'home office':'Home Office', 'hm treasury':'HM Treasury',
        'treasury':'HM Treasury', 'dcms':'DCMS', 'moj':'MOJ',
        'dsit':'DSIT', 'cabinet office':'Cabinet Office',
    }
    return MAP.get(str(v).lower().strip(), 'Other')

def norm_org_size(v):
    if pd.isna(v): return None
    s = str(v).lower()
    if 'micro' in s or '1-9' in s or '1\u20139' in s: return 'Micro'
    if 'small' in s or '10-' in s or '10\u2013' in s: return 'Small'
    if 'medium' in s or '50-' in s or '50\u2013' in s: return 'Medium'
    if 'large' in s or '250' in s or '1000' in s: return 'Large'
    return 'Medium'

def norm_content_type(v):
    if pd.isna(v): return 'News'
    MAP = {
        'investigation announcement':'Investigation Announcement',
        'press release':'Press Release','blog':'Blog',
        'news':'News','statement':'Statement',
    }
    return MAP.get(str(v).lower().strip(), 'News')

def norm_item_type(v):
    if pd.isna(v): return 'Other'
    s = str(v).lower().strip()
    if 'ico' in s and ('alloc' in s or 'budget' in s or 'resource' in s): return 'ICO Allocation'
    if 'enforcement' in s: return 'Enforcement Budget'
    if 'tech' in s: return 'Tech Regulation Fund'
    if 'ai safety' in s: return 'AI Safety Spending'
    if 'digital' in s: return 'Digital Infrastructure'
    return 'Other'

def norm_gov_position(v):
    if pd.isna(v): return 'Unclear'
    MAP = {
        'supportive of enforcement':'Supportive of Enforcement',
        'supportive':'Supportive of Enforcement',
        'neutral':'Neutral','resistant':'Resistant','unclear':'Unclear',
    }
    return MAP.get(str(v).lower().strip(), 'Unclear')

def norm_account_cat(v):
    if pd.isna(v): return 'Other'
    MAP = {
        'minister':'Minister','shadow minister':'Shadow Minister',
        'mp':'MP','aide':'Aide','party account':'Party Account',
        'regulator':'Other','other':'Other',
    }
    return MAP.get(str(v).lower().strip(), 'Other')

def norm_stance(v):
    if pd.isna(v): return 'Neutral'
    MAP = {
        'pro-enforcement':'Pro-enforcement','pro enforcement':'Pro-enforcement',
        'neutral':'Neutral','deregulatory':'Deregulatory','mixed':'Mixed',
    }
    return MAP.get(str(v).lower().strip(), 'Neutral')

BOOL = parse_bool
DATE = parse_date
UUID = ensure_uuid

# ── Table definitions ─────────────────────────────────────────────────────────
# (table_name, csv_prefix, [columns], {col: cleaner})

TABLE_DEFS = [
    ('l1_bills_in_parliament','l1_bills',[
        'bill_id','parliament_bill_id','bill_type','bill_title','session',
        'event_type','event_date','house','bill_stage_numeric','bill_status',
        'expected_commencement','processing_activities','relevance_score',
        'relevance_tag','nlp_confidence','obligation_direction','affects_ico',
        'source_url','rss_guid','ingested_at','manually_reviewed',
    ],{'bill_id':UUID,'event_date':DATE,'expected_commencement':DATE,'affects_ico':BOOL,'manually_reviewed':BOOL}),

    ('l2_statutory_instruments','l2_statutory_instruments',[
        'si_id','si_number','si_title','si_type','parent_act_id','parent_act_name',
        'made_date','laid_date','force_date','provisions_commenced','si_status',
        'processing_activities','relevance_score','relevance_tag','nlp_confidence',
        'obligation_type','affects_ico','source_url','rss_guid','ingested_at','manually_reviewed',
    ],{'si_id':UUID,'made_date':DATE,'laid_date':DATE,'force_date':DATE,'affects_ico':BOOL,'manually_reviewed':BOOL}),

    ('p1_government_speeches','p1_government_speeches',[
        'speech_id','title','speaker_name','speaker_role','party','department',
        'speech_date','speech_url','rss_guid','topic_relevance_score',
        'processing_activities','relevance_tag','priority_level',
        'regulatory_stance','enforcement_signal','nlp_confidence','ico_mentioned',
        'ingested_at','raw_text','manually_reviewed',
    ],{'speech_id':UUID,'speech_date':DATE,'department':norm_department,'regulatory_stance':norm_stance,'ico_mentioned':BOOL,'manually_reviewed':BOOL}),

    ('p2_party_manifestos','p2_manifestos',[
        'manifesto_id','party','election_year','commitment_text',
        'processing_activities','topic_tags','obligation_direction','priority_level',
        'governing_party','manifesto_project_id','source_url','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'manifesto_id':UUID,'governing_party':BOOL,'manually_reviewed':BOOL}),

    ('p3_budget_documents','p3_budget_pdf',[
        'budget_id','budget_year','budget_date','item_type','item_description',
        'amount_gbp','yoy_change_pct','yoy_direction','ico_budget_flag',
        'enforcement_signal','source_url','ingested_at','nlp_confidence','manually_reviewed',
    ],{'budget_id':UUID,'budget_date':DATE,'item_type':norm_item_type,'ico_budget_flag':BOOL,'manually_reviewed':BOOL}),

    ('p4_electoral_signals','p4_electoral_signals',[
        'electoral_id','record_date','last_election_date','next_election_due',
        'governing_party','governing_poll_ptc','opposition_poll_ptc','poll_source',
        'prediction_market_prob','gov_change_12m','ingested_at',
    ],{'electoral_id':UUID,'record_date':DATE,'last_election_date':DATE,'next_election_due':DATE}),

    ('p5_social_listening','p5_social_listening',[
        'social_id','platform','account_handle','account_name','account_category',
        'party','party_power','post_date','post_id_platform','raw_text',
        'processing_activities','topic_relevance_score','topic_tags','priority_level',
        'regulatory_stance','engagement_score','ingested_at','nlp_confidence','manually_reviewed',
    ],{'social_id':UUID,'post_date':DATE,'account_category':norm_account_cat,'regulatory_stance':norm_stance,'party_power':BOOL,'manually_reviewed':BOOL}),

    ('p6_parliamentary_qa','p6_parliamentary_qa',[
        'pqa_id','question_date','answer_date','question_type','asking_mp',
        'asking_party','asking_party_gov','answering_minister','answering_department',
        'answering_party','question_text','answer_text','processing_activities',
        'topic_tags','topic_relevance_score','priority_level','government_position',
        'ico_mentioned','enforcement_signal','source_url','rss_guid',
        'ingested_at','nlp_confidence','manually_reviewed',
    ],{'pqa_id':UUID,'question_date':DATE,'answer_date':DATE,'asking_party_gov':BOOL,'government_position':norm_gov_position,'ico_mentioned':BOOL,'manually_reviewed':BOOL}),

    ('r1_enforcement_register','r1_ico_enforcement',[
        'enforcement_id','ico_reference','org_name','org_type','org_size',
        'action_date','action_type','outcome','penalty_gbp','penalty_as_max',
        'severity_tier','aggravating_factors','mitigating_factors','appealed',
        'appeal_outcome','processing_activities','legislation_breached',
        'gdpr_principles','special_category_data','cross_border','ai_specific',
        'prior_ico_contact','prior_contact_types','prior_contact_count',
        'days_prior_contact','org_type_recidivism_rate','enforcement_signal',
        'nlp_confidence','source_url','raw_summary','ingested_at','manually_reviewed',
    ],{'enforcement_id':UUID,'action_date':DATE,'org_size':norm_org_size,'appealed':BOOL,
       'special_category_data':BOOL,'cross_border':BOOL,'ai_specific':BOOL,
       'prior_ico_contact':BOOL,'manually_reviewed':BOOL}),

    ('r2_ico_news','r2_ico_news',[
        'news_id','title','publication_date','content_type','processing_activities',
        'topic_tags','topic_relevance_score','signal_investigation',
        'signal_consultation','enforcement_signal','source_url','rss_guid',
        'raw_text','ingested_at','nlp_confidence','manually_reviewed',
    ],{'news_id':UUID,'publication_date':DATE,'content_type':norm_content_type,
       'signal_investigation':BOOL,'signal_consultation':BOOL,'manually_reviewed':BOOL}),

    ('r3_ico_consultations','r3_ico_consultations',[
        'consultation_id','title','publication_date','document_type',
        'consultation_status','consultation_closes','processing_activities',
        'topic_tags','topic_relevance_score','obligation_direction',
        'enforcement_signal','follows_enforcement','source_url','rss_guid',
        'raw_text','ingested_at','nlp_confidence','manually_reviewed',
    ],{'consultation_id':UUID,'publication_date':DATE,'consultation_closes':DATE,
       'follows_enforcement':BOOL,'manually_reviewed':BOOL}),

    ('r4_secondary_regulators','r4_secondary_regulators',[
        'secondary_id','regulator','action_date','action_type','title','org_name',
        'org_type','processing_activities','topic_tags','topic_relevance_score',
        'cross_regulator_flag','ico_referral','enforcement_signal','source_url',
        'rss_guid','raw_text','ingested_at','nlp_confidence','manually_reviewed',
    ],{'secondary_id':UUID,'action_date':DATE,'cross_regulator_flag':BOOL,'ico_referral':BOOL,'manually_reviewed':BOOL}),

    ('r5_international_bodies','r5_international_bodies',[
        'international_id','body','jurisdiction','action_date','action_type',
        'title','org_name','org_type','penalty_eur','processing_activities',
        'topic_tags','topic_relevance_score','uk_company_involved','gdpr_articles',
        'ico_signal_strength','source_url','gdpr_tracker_id','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'international_id':UUID,'action_date':DATE,'uk_company_involved':BOOL,'manually_reviewed':BOOL}),

    ('r6_drcf','r6_drcf',[
        'drcf_id','publication_date','document_type','title','participating_bodies',
        'processing_activities','topic_tags','topic_relevance_score','ico_lead',
        'enforcement_signal','coordinated_action_flag','source_url','rss_guid',
        'raw_text','ingested_at','nlp_confidence','manually_reviewed',
    ],{'drcf_id':UUID,'publication_date':DATE,'ico_lead':BOOL,'coordinated_action_flag':BOOL,'manually_reviewed':BOOL}),

    ('j1_supreme_court','j1_supreme_court',[
        'supreme_id','case_name','neutral_citation','decision_date','subject_matter',
        'appellant','respondent','appellant_type','respondent_type','ico_role',
        'ico_position_upheld','outcome_direction','outcome_summary','precedent_weight',
        'processing_activities','gdpr_articles','gdpr_principles','damages_awarded',
        'damages_amount','ai_specific','widens_controller_liability',
        'restricts_ico_powers','enforcement_signal','case_url','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'supreme_id':UUID,'decision_date':DATE,'ico_position_upheld':BOOL,'damages_awarded':BOOL,
       'ai_specific':BOOL,'widens_controller_liability':BOOL,'restricts_ico_powers':BOOL,'manually_reviewed':BOOL}),

    ('j2_court_of_appeal','j2_court_of_appeal',[
        'appeal_id','case_name','neutral_citation','decision_date','division',
        'subject_matter','appellant_type','respondent_type','ico_role',
        'ico_position_upheld','outcome_direction','outcome_summary','precedent_weight',
        'processing_activities','gdpr_articles','gdpr_principles','damages_awarded',
        'damages_amount','ai_specific','widens_controller_liability',
        'restricts_ico_powers','enforcement_signal','case_url','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'appeal_id':UUID,'decision_date':DATE,'ico_position_upheld':BOOL,'damages_awarded':BOOL,
       'ai_specific':BOOL,'widens_controller_liability':BOOL,'restricts_ico_powers':BOOL,'manually_reviewed':BOOL}),

    ('j3_information_rights_tribunal','j3_tribunal',[
        'tribunal_id','case_reference','tier','decision_date','case_type',
        'appellant_type','ico_role','ico_position_upheld','outcome_direction',
        'original_penalty_gbp','revised_penalty_gbp','penalty_reduction_pct',
        'appeals_ground','processing_activities','gdpr_articles','ai_specific',
        'precedent_weight','enforcement_signal','case_url','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'tribunal_id':UUID,'decision_date':DATE,'ico_position_upheld':BOOL,'ai_specific':BOOL,'manually_reviewed':BOOL}),

    ('j4_high_court','j4_high_court',[
        'highcourt_id','case_name','neutral_citation','decision_date','division',
        'case_type','ico_role','ico_position_upheld','jr_permission_granted',
        'outcome_direction','outcome_summary','precedent_weight',
        'processing_activities','gdpr_articles','gdpr_principles','damages_awarded',
        'damages_amount','ai_specific','widens_controller_liability',
        'restricts_ico_powers','enforcement_signal','case_url','ingested_at',
        'nlp_confidence','manually_reviewed',
    ],{'highcourt_id':UUID,'decision_date':DATE,'ico_position_upheld':BOOL,'jr_permission_granted':BOOL,
       'damages_awarded':BOOL,'ai_specific':BOOL,'widens_controller_liability':BOOL,
       'restricts_ico_powers':BOOL,'manually_reviewed':BOOL}),

    ('m1_ngo_activity','m1_ngo_activity',[
        'ngo_activity_id','ngo_name','publication_date','activity_type','title',
        'source_url','target_org','ico_named','formal_complaint','complaint_ref',
        'legal_action','content_summary','processing_activities',
        'topic_relevance_score','enforcement_stance','gdpr_articles',
        'ingested_at','nlp_confidence','manually_reviewed',
    ],{'ngo_activity_id':UUID,'publication_date':DATE,'ico_named':BOOL,'formal_complaint':BOOL,'legal_action':BOOL,'manually_reviewed':BOOL}),

    ('m2_media_press','m2_media_press',[
        'press_id','publication_date','outlet','outlet_tier','headline',
        'source_url','author','story_type','target_org','ico_mentioned','ico_action',
        'content_summary','processing_activities','topic_relevance_score',
        'enforcement_stance','ingested_at','nlp_confidence','manually_reviewed',
    ],{'press_id':UUID,'publication_date':DATE,'ico_mentioned':BOOL,'ico_action':BOOL,'manually_reviewed':BOOL}),

    ('i1_volume_statistics','i1_complaint_volume',[
        'stat_id','period_start','period_end','period_type','ico_sector',
        'sector_relevance','complaint_count','data_breach_count',
        'complaint_resolved','complaint_resolved_pct','yoy_change_pct',
        'qoq_change_pct','avg_3period','pct_above_avg','spike_flag',
        'source_doc','source_url','ingested_at','manually_reviewed',
    ],{'stat_id':UUID,'period_start':DATE,'period_end':DATE,'complaint_resolved':BOOL,'spike_flag':BOOL,'manually_reviewed':BOOL}),

    ('i2_volume_scores','i2_volume_scores',[
        'score_id','ico_sector','ref_period_start','ref_period_end',
        'complaint_count_used','avg_3period_used','volume_factor',
        'trend_direction','spike_active','sector_risk_modifier',
        'data_lag','stale_flag','computed_at',
    ],{'score_id':UUID,'ref_period_start':DATE,'ref_period_end':DATE,'spike_active':BOOL,'stale_flag':BOOL}),
]

# ── Loader ────────────────────────────────────────────────────────────────────

def find_csv(prefix):
    candidates = sorted(DATA_DIR.glob(f'{prefix}*.csv'), reverse=True)
    return candidates[0] if candidates else None


def load_table(table, prefix, columns, cleaners, truncate=False):
    csv_path = find_csv(prefix)
    if not csv_path:
        print(f'  -  {table:<45} no CSV found')
        return 0, 0, 0

    try:
        df_raw = pd.read_csv(csv_path, dtype=str, low_memory=False)
    except Exception as e:
        print(f'  \u2717  {table:<45} cannot read CSV: {e}')
        return 0, 0, 0

    # Only keep columns that exist in both CSV and our definition
    available = [c for c in columns if c in df_raw.columns]
    missing   = [c for c in columns if c not in df_raw.columns]
    if missing:
        print(f'       \u26a0  columns missing from CSV (will be NULL): {missing}')

    df = df_raw[available].copy()

    # Apply cleaners
    for col in df.columns:
        fn = cleaners.get(col, clean_str)
        df[col] = df[col].apply(fn)

    # Add missing columns as None
    for col in columns:
        if col not in df.columns:
            df[col] = None
    df = df[columns]
    total = len(df)

    if truncate:
        with engine.connect() as conn:
            conn.execute(text(f'TRUNCATE {table} CASCADE'))
            conn.commit()

    loaded = skipped = 0
    errors = []
    with engine.connect() as conn:
        for _, row in df.iterrows():
            row_dict = {k: v for k, v in row.items() if v is not None}
            if not row_dict:
                skipped += 1
                continue
            cols = ', '.join(f'"{c}"' for c in row_dict)
            vals = ', '.join(f':{c}' for c in row_dict)
            try:
                result = conn.execute(
                    text(f'INSERT INTO {table} ({cols}) VALUES ({vals}) ON CONFLICT DO NOTHING'),
                    row_dict
                )
                loaded += 1 if result.rowcount > 0 else 0
                skipped += 1 if result.rowcount == 0 else 0
            except Exception as e:
                skipped += 1
                err = str(e).split('\n')[0][:120]
                if err not in errors:
                    errors.append(err)
        conn.commit()

    status = '\u2713' if not errors else '\u26a0'
    print(f'  {status}  {table:<45} {loaded:>5,} loaded  {skipped:>4,} skipped  ({total:,} in CSV)')
    for e in errors[:2]:
        print(f'       \u2192 {e}')
    if len(errors) > 2:
        print(f'       \u2192 ...and {len(errors)-2} more unique error types')
    return total, loaded, skipped


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--table',    default=None, help='Only load tables starting with this (e.g. r1)')
    parser.add_argument('--truncate', action='store_true', help='Clear tables before loading')
    args = parser.parse_args()

    if not DATA_DIR.exists():
        print(f'\u2717 Data folder not found: {DATA_DIR.resolve()}')
        sys.exit(1)

    print('Creating tables...')
    create_leg(); create_reg(); create_jud(); create_pol(); create_ico(); create_med()
    print('\u2713 Tables ready\n')

    if args.truncate:
        print('\u26a0  --truncate flag set: tables will be cleared before loading\n')

    print(f'Loading from: {DATA_DIR.resolve()}\n')
    print(f'  {"Table":<47} {"Loaded":>7} {"Skipped":>8} {"CSV total":>10}')
    print('  ' + '\u2500' * 74)

    totals = [0, 0, 0]
    for table, prefix, columns, cleaners in TABLE_DEFS:
        if args.table and not table.startswith(args.table):
            continue
        r = load_table(table, prefix, columns, cleaners, truncate=args.truncate)
        for i, v in enumerate(r):
            totals[i] += v

    print('  ' + '\u2500' * 74)
    print(f'  Total: {totals[1]:,} rows loaded, {totals[2]:,} skipped from {totals[0]:,} CSV rows\n')

    if totals[1] > 0:
        print('Next steps:')
        print('  python ers_scoring.py --backfill')
        print('  uvicorn api:app --reload --port 8000')
        print('  curl http://localhost:8000/api/v1/health')

if __name__ == '__main__':
    main()
