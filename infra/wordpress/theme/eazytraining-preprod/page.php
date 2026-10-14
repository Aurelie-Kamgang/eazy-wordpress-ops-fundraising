<?php get_header(); ?>
<section class="page-hero"><div class="container"><span class="section-kicker">EAZYTRAINING IMPACT</span><h1><?php the_title(); ?></h1></div></section>
<section class="section page-content"><div class="container content-shell"><?php while (have_posts()) : the_post(); the_content(); endwhile; ?></div></section>
<?php get_footer(); ?>
