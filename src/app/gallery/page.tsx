export default function GalleryPage() {
  return <main>
    <h1>Photo Gallery / ಫೋಟೋ ಗ್ಯಾಲರಿ</h1>
    <p>Only approved albums and photographs should be visible publicly.</p>
    <article className="card"><h2>No published albums yet</h2><p className="muted">Uploads require authenticated administrator access and storage policies. Configure Supabase Storage before accepting real photos.</p></article>
  </main>;
}
