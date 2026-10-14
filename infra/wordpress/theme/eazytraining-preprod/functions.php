<?php
if (!defined('ABSPATH')) { exit; }

function eazyimpact_setup() {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('custom-logo', [
        'height' => 80,
        'width' => 260,
        'flex-height' => true,
        'flex-width' => true,
    ]);
    add_theme_support('html5', ['search-form','comment-form','comment-list','gallery','caption','style','script']);
    register_nav_menus([
        'primary' => __('Navigation principale', 'eazytraining-preprod'),
        'footer'  => __('Navigation pied de page', 'eazytraining-preprod'),
    ]);
}
add_action('after_setup_theme', 'eazyimpact_setup');

function eazyimpact_assets() {
    wp_enqueue_style(
        'eazyimpact-main',
        get_template_directory_uri() . '/assets/css/main.css',
        [],
        '2.0.0'
    );
}
add_action('wp_enqueue_scripts', 'eazyimpact_assets');

function eazyimpact_first_form_id() {
    $forms = get_posts([
        'post_type' => 'give_forms',
        'post_status' => 'publish',
        'numberposts' => 1,
        'orderby' => 'date',
        'order' => 'DESC',
        'fields' => 'ids',
    ]);
    return !empty($forms) ? (int) $forms[0] : 0;
}

function eazyimpact_total_forms() {
    $counts = wp_count_posts('give_forms');
    return isset($counts->publish) ? (int) $counts->publish : 0;
}
