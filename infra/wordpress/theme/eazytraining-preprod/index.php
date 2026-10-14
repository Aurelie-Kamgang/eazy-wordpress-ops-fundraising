<?php get_header(); ?>
<section class="page-hero"><div class="container"><span class="section-kicker">ACTUALITÉS</span><h1><?php bloginfo('name'); ?></h1></div></section>
<section class="section"><div class="container content-shell">
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
<article class="post-card"><h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2><?php the_excerpt(); ?></article>
<?php endwhile; else : ?><p>Aucun contenu publié pour le moment.</p><?php endif; ?>
</div></section>
<?php get_footer(); ?>
