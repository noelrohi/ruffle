use ruffle_test_framework::environment::Environment;
use ruffle_test_framework::options::TestOptions;
use ruffle_test_framework::runner::TestStatus;
use ruffle_test_framework::test::Test;
use ruffle_test_framework::vfs::{PhysicalFS, VfsPath};
use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use std::thread::sleep;
use tracing::field::Field;
use tracing_subscriber::layer::{Context, SubscriberExt};

#[derive(Clone, Default)]
struct ErrorLog(Arc<Mutex<Vec<String>>>);

impl<S: tracing::Subscriber> tracing_subscriber::Layer<S> for ErrorLog {
    fn on_event(&self, event: &tracing::Event<'_>, _ctx: Context<'_, S>) {
        if *event.metadata().level() == tracing::Level::ERROR {
            let mut message = String::new();
            event.record(&mut |_: &Field, value: &dyn Debug| {
                message.push_str(&format!("{value:?}"));
            });
            self.0.lock().unwrap().push(message);
        }
    }
}

pub fn loader_cancellations_are_not_errors(
    environment: &impl Environment,
) -> Result<(), libtest_mimic::Failed> {
    let errors = ErrorLog::default();
    let subscriber = tracing_subscriber::registry().with(errors.clone());
    tracing::subscriber::with_default(subscriber, || -> Result<(), libtest_mimic::Failed> {
        for (name, num_frames) in [
            ("loader_cancel_in_handlers", 400),
            ("loader_reuse_and_close", 60),
        ] {
            let test = &Test::from_options(
                TestOptions {
                    num_frames: Some(num_frames),
                    output_path: "output.txt".into(),
                    ..Default::default()
                },
                VfsPath::new(PhysicalFS::new(format!("tests/swfs/avm2/{name}/"))),
                name.to_string(),
            )?;
            let mut runner = test.create_test_runner(environment)?;
            loop {
                match runner.tick()? {
                    TestStatus::Continue => {}
                    TestStatus::Sleep(duration) => sleep(duration),
                    TestStatus::Finished => break,
                }
            }
        }
        Ok(())
    })?;

    let cancelled: Vec<_> = errors
        .0
        .lock()
        .unwrap()
        .iter()
        .filter(|message| message.contains("ancelled"))
        .cloned()
        .collect();
    if !cancelled.is_empty() {
        return Err(format!(
            "{} cancelled loads logged as errors: {cancelled:#?}",
            cancelled.len()
        )
        .into());
    }
    Ok(())
}
